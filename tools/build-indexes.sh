#!/usr/bin/env bash
# Regenere un index.md par dossier eligible, sous chaque racine passee en argument.
# Genere uniquement : ne jamais editer un index.md a la main.
#
# usage: build-indexes.sh <racine...>

set -u

if [ "$#" -eq 0 ]; then
  echo "usage: build-indexes.sh <racine...>" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VAULT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STD_LINK_TARGET="$VAULT_ROOT/rules/RULES-2026-08-21-115658-document-linking-standard.md"

PRUNE_NAMES='.git .githooks .claude .codex graphify-out tools patterns node_modules state .venv venv __pycache__'

# Extrait "chemin<TAB>title<TAB>type" en un seul processus awk pour tous les
# fichiers d'un dossier (au lieu d'un appel par fichier par champ : le fork de
# processus est le cout dominant sous Git Bash/Windows).
list_fields() {
  awk '
    FNR==1 { infm=0; title=""; type="" }
    FNR==1 && $0=="---" { infm=1; next }
    infm && $0=="---" { infm=0 }
    infm && /^title:/ { v=$0; sub(/^title:[[:space:]]*/,"",v); gsub(/^"|"$/,"",v); title=v }
    infm && /^type:/  { v=$0; sub(/^type:[[:space:]]*/,"",v);  gsub(/^"|"$/,"",v);  type=v }
    ENDFILE {
      t=title; if (t=="") t="(sans titre)"
      ty=type; if (ty=="") ty="inconnu"
      print FILENAME "\t" t "\t" ty
    }
  ' "$@" 2>/dev/null
}

# Extrait, a partir d'une liste de fichiers deja etablie (une seule ligne de
# commande find pour toute la racine, cout de fork domine sous Git
# Bash/Windows), les paires "chemin<TAB>valeur-brute" du champ front-matter
# supersedes (valeur scalaire ou items de liste YAML indentee).
extract_supersedes_raw() {
  tr '\n' '\0' | xargs -0 awk '
    FNR==1 { infm=0; insup=0 }
    FNR==1 && $0=="---" { infm=1; next }
    infm && $0=="---" { infm=0; insup=0; next }
    infm && /^supersedes:/ {
      insup=1
      line=$0
      sub(/^supersedes:[[:space:]]*/,"",line)
      if (line != "") print FILENAME "\t" line
      next
    }
    infm && insup {
      if ($0 ~ /^[[:space:]]+-/) {
        line=$0
        sub(/^[[:space:]]+-[[:space:]]*/,"",line)
        print FILENAME "\t" line
      } else {
        insup=0
      }
    }
  ' 2>/dev/null
}

COUNT=0

for ROOT in "$@"; do
  [ -d "$ROOT" ] || continue
  ROOT_ABS="$(cd "$ROOT" && pwd)"

  PRUNE_EXPR=""
  for N in $PRUNE_NAMES; do
    PRUNE_EXPR="$PRUNE_EXPR -o -name $N"
  done

  # --- Marquage des documents remplaces (objectif B, Mission 029) ---
  # Une seule liste de fichiers .md pour toute la racine, reutilisee pour la
  # carte des remplacements et pour la liste plate (evite un second find sur
  # l'arbre complet : le fork de processus est le cout dominant ici aussi).
  ALL_MD_FILES="$(find "$ROOT_ABS" \( -false $PRUNE_EXPR \) -prune -o -type f -name '*.md' ! -name 'index.md' -print)"

  # Carte basename-remplace -> basename-remplacant, portee a cette racine.
  declare -A SUPERSEDED_BY=()
  if [ -n "$ALL_MD_FILES" ]; then
    while IFS="$(printf '\t')" read -r SUP_FPATH SUP_RAWVAL; do
      [ -z "$SUP_FPATH" ] && continue
      if [[ "$SUP_RAWVAL" =~ ([A-Za-z0-9._-]+\.md) ]]; then
        SUPERSEDED_BY["${BASH_REMATCH[1]}"]="${SUP_FPATH##*/}"
      fi
    done < <(printf '%s\n' "$ALL_MD_FILES" | extract_supersedes_raw)
  fi

  # Liste plate, lisible par machine, des fichiers remplaces sous cette
  # racine : chemin relatif a la racine, un par ligne. Emplacement choisi :
  # <racine>/superseded-files.txt (voir rapport Mission 029). Lu par
  # tools/find-in-vault.sh pour suffixer les lignes de resultat ; absence
  # tolerée, sans erreur.
  SUPERSEDED_LIST_FILE="$ROOT_ABS/superseded-files.txt"
  : > "$SUPERSEDED_LIST_FILE"
  if [ "${#SUPERSEDED_BY[@]}" -gt 0 ] && [ -n "$ALL_MD_FILES" ]; then
    while IFS= read -r F; do
      FN="${F##*/}"
      if [ -n "${SUPERSEDED_BY[$FN]+x}" ]; then
        realpath --relative-to="$ROOT_ABS" "$F"
      fi
    done <<EOF_ALLMD
$ALL_MD_FILES
EOF_ALLMD
  fi | sort > "$SUPERSEDED_LIST_FILE"

  find "$ROOT_ABS" \( -false $PRUNE_EXPR \) -prune -o -type d -print | while IFS= read -r DIR; do
    MD_FILES="$(find "$DIR" -maxdepth 1 -type f -name '*.md' ! -name 'index.md' | sort)"
    [ -z "$MD_FILES" ] && continue

    INDEX="$DIR/index.md"
    TITLE="$(basename "$DIR")"

    REL_STD="$(realpath --relative-to="$DIR" "$STD_LINK_TARGET" 2>/dev/null)"
    case "$REL_STD" in
      ../*|./*) : ;;
      *) REL_STD="./$REL_STD" ;;
    esac
    HORS_SUFFIX=""
    case "$DIR" in
      "$VAULT_ROOT"|"$VAULT_ROOT"/*) : ;;
      *) HORS_SUFFIX=" (hors Vault)" ;;
    esac

    {
      echo "---"
      echo "type: index"
      echo "title: \"Index — $TITLE\""
      echo "description: \"Index généré automatiquement par tools/build-indexes.sh.\""
      echo "status: active"
      echo "generated_by: tools/build-indexes.sh"
      echo "---"
      echo ""
      echo "# Index — $TITLE"
      echo ""
      echo "Index généré automatiquement. Ne pas éditer à la main : régénérer via \`tools/build-indexes.sh\`."
      echo ""
      echo "## Contenu"
      echo ""
      list_fields $MD_FILES | sort | while IFS="$(printf '\t')" read -r F T TY; do
        [ -z "$F" ] && continue
        FN="${F##*/}"
        MARK=""
        if [ -n "${SUPERSEDED_BY[$FN]+x}" ]; then
          MARK=" — REMPLACÉ par ${SUPERSEDED_BY[$FN]}"
        fi
        echo "- \`$FN\` — $T · $TY$MARK"
      done
      echo ""
      echo "## Liens"
      echo ""
      if [ -n "$REL_STD" ]; then
        echo "- \`prescrit par\` — [Standard de liens entre documents]($REL_STD)$HORS_SUFFIX"
      fi
    } > "$INDEX"

    echo "$INDEX" >&2
  done
done
