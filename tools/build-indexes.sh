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

COUNT=0

for ROOT in "$@"; do
  [ -d "$ROOT" ] || continue
  ROOT_ABS="$(cd "$ROOT" && pwd)"

  PRUNE_EXPR=""
  for N in $PRUNE_NAMES; do
    PRUNE_EXPR="$PRUNE_EXPR -o -name $N"
  done

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
        echo "- \`$FN\` — $T · $TY"
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
