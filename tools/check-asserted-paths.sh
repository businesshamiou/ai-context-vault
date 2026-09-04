#!/usr/bin/env bash
# Gardien des chemins affirmes : confronte au systeme de fichiers les chemins
# cites en prose (entre accents graves simples) par le corpus normatif vivant
# de ce depot. Lecture seule : ne corrige jamais un defaut trouve, se
# contente de refuser et de le lister. Est cable sur vault/.githooks/pre-commit
# (mesure 2026-09-04, Mission 132) -- l'en-tete precedente affirmait a tort
# l'absence de cablage depuis la Mission 103 ; execution manuelle possible
# aussi, resultat rapporte par l'appelant dans ce cas.
#
# Perimetre : fichiers .md suivis de ce depot dont le front-matter `type`
# vaut `rules` ou `decision`, ou qui vivent sous knowledge/, templates/, ou
# a la racine du depot -- et dont le `status` n'est pas `superseded`.
#
# Un jeton n'est examine que s'il nomme un fichier (extension presente dans
# son dernier segment, y compris la forme point-fichier des dotfiles comme
# .graphifyignore) : un dossier nu (`captures/`, `missions/`, ...) n'est
# jamais examine -- c'est la regle qui laisse intactes les citations
# prescriptives d'un gabarit ou d'un standard generique.
#
# Un jeton immediatement suivi, dans la prose, de la marque litterale
# `(supprimé, Mission NNN)` ou `(supprimé)` est accepte sans resolution.
#
# usage: check-asserted-paths.sh

set -u

# Garde Git (Mission 125, meme raison qu'a check-secrets.sh) : refus
# explicite hors d'un depot, plutot qu'un $VAULT_ROOT vide qui rendait ce
# gardien lecture-seule silencieusement inoffensif (0 fichier examine, faux
# PASS) au lieu de refuser -- mesure au rapport 124.
VAULT_ROOT="$(git rev-parse --show-toplevel)" || {
  echo "REFUS : hors d'un depot Git : gardien non executable." >&2
  exit 1
}
WORKSPACE_ROOT="$(cd "$VAULT_ROOT/.." && pwd)"
SIBLING_NAME="${ASSERTED_PATHS_SIBLING_NAME:-workshop-build}"
SIBLING_ROOT="$WORKSPACE_ROOT/$SIBLING_NAME"

FAIL=0
CHECKED=0
IGNORED_DIR=0
ACCEPTED_MARKED=0
DEFECT_COUNT=0

# Tabulation calculee une seule fois (Mission 127) : evite de relancer un
# processus printf a chaque iteration du while ci-dessous (meme cout que
# celui mesure et corrige dans check-distribution-manifest.sh).
TAB="$(printf '\t')"

# --- 1. Selection des fichiers du perimetre ---
ALL_MD="$(git -C "$VAULT_ROOT" ls-files -- '*.md')"

# Pre-passe groupee (Mission 127) : un seul processus awk pour tout le corpus
# au lieu d'un awk par fichier dans is_in_perimeter()/is_superseded() -- sur
# ce poste (Git Bash/Windows) le fork de processus est le cout dominant, pas
# le traitement lui-meme (meme diagnostic et meme patron que
# tools/build-indexes.sh list_fields() : FNR==1 reinitialise l'etat par
# fichier dans un unique appel awk, ENDFILE emet une ligne par fichier).
# Comportement inchange : memes deux champs (type/status) lus dans le meme
# bloc front-matter --- ... --- au meme sens, mesure par l'oracle de la
# Mission 127 (sortie byte-identique avant/apres).
FM_TABLE="$(printf '%s\n' "$ALL_MD" | sed "s#^#$VAULT_ROOT/#" | tr '\n' '\0' | xargs -0 awk '
  FNR==1 { infm=0; type=""; status="" }
  FNR==1 && $0=="---" { infm=1; next }
  infm && $0=="---" { infm=0 }
  infm && /^type:/   { v=$0; sub(/^type:[[:space:]]*/,"",v);   gsub(/^"|"$/,"",v); type=v }
  infm && /^status:/ { v=$0; sub(/^status:[[:space:]]*/,"",v); gsub(/^"|"$/,"",v); status=v }
  ENDFILE { print FILENAME "\t" type "\t" status }
' 2>/dev/null)"

declare -A FM_TYPE=() FM_STATUS=()
while IFS="$TAB" read -r fpath ftype fstatus; do
  [ -z "$fpath" ] && continue
  frel="${fpath#"$VAULT_ROOT"/}"
  FM_TYPE["$frel"]="$ftype"
  FM_STATUS["$frel"]="$fstatus"
done <<EOF_FMTABLE
$FM_TABLE
EOF_FMTABLE

is_in_perimeter() {
  local rel="$1"
  case "$rel" in
    */*) : ;;
    *) return 0 ;;  # a la racine du depot
  esac
  case "$rel" in
    knowledge/*|templates/*) return 0 ;;
  esac
  local ftype="${FM_TYPE[$rel]:-}"
  [ "$ftype" = "rules" ] && return 0
  [ "$ftype" = "decision" ] && return 0
  return 1
}

is_superseded() {
  local rel="$1"
  local status="${FM_STATUS[$rel]:-}"
  [ "$status" = "superseded" ]
}

PERIMETER_FILES=""
while IFS= read -r rel; do
  [ -z "$rel" ] && continue
  if is_in_perimeter "$rel" && ! is_superseded "$rel"; then
    PERIMETER_FILES="$PERIMETER_FILES
$rel"
  fi
done <<EOF_ALLMD
$ALL_MD
EOF_ALLMD

# --- 2. Extraction et verification, fichier par fichier ---
# Un jeton "nomme un fichier" si son dernier segment (apres / ou \) commence
# par un point (dotfile, ex. .graphifyignore -- toujours examine, quelle que
# soit la liste blanche), ou si ce dernier segment se termine par l'une des
# extensions de la liste blanche ci-dessous. La liste blanche est mesuree,
# pas inventee : extensions distinctes portees par les fichiers suivis de
# vault et workshop-build (git ls-files), Mission 092. Remplace l'ancienne
# heuristique "un point suivi d'au moins un caractere", qui comptait des
# non-chemins (numero de version, cle de configuration Git) parmi les
# defauts (mesure Mission 091).
# Exception, meme principe que les dossiers nus (ci-dessous) : un jeton
# reduit a un point suivi d'une seule extension de la liste blanche, sans
# autre segment ni autre point (ex. `.md`), nomme un format et non un
# fichier -- il n'est jamais examine, quel que soit son contenu (Mission
# 100). Distinct d'un dotfile comme .graphifyignore, qui n'a pas de
# segment "nom" separe de son extension.
names_a_file() {
  local base="$1"
  base="${base%%/}"
  base="${base##*/}"
  base="${base##*\\}"
  case "$base" in
    .md|.yaml|.sh|.txt|.py|.json|.svg|.js|.html|.example|.cjs) return 1 ;;
  esac
  case "$base" in
    .*) return 0 ;;
  esac
  case "$base" in
    *.md|*.yaml|*.sh|*.txt|*.py|*.json|*.svg|*.js|*.html|*.example|*.cjs) return 0 ;;
  esac
  return 1
}

resolve_token() {
  local token="$1" source_dir="$2"
  for root in "$VAULT_ROOT" "$source_dir" "$SIBLING_ROOT" "$WORKSPACE_ROOT"; do
    if [ -e "$root/$token" ]; then
      return 0
    fi
  done
  # jeton deja absolu
  case "$token" in
    /*|[A-Za-z]:\\*|[A-Za-z]:/*)
      [ -e "$token" ] && return 0
      ;;
  esac
  return 1
}

while IFS= read -r rel; do
  [ -z "$rel" ] && continue
  FULL="$VAULT_ROOT/$rel"
  # dirname pur bash (Mission 127) : $FULL est toujours un chemin absolu
  # avec au moins un "/", la substitution est donc toujours equivalente ;
  # remplace un processus dirname par fichier du perimetre.
  SOURCE_DIR="${FULL%/*}"

  IN_FENCE=0
  SECTION="(préambule)"
  LINE_NO=0

  while IFS= read -r line || [ -n "$line" ]; do
    LINE_NO=$((LINE_NO + 1))

    LTRIM="${line#"${line%%[![:space:]]*}"}"
    case "$LTRIM" in
      '```'*|'~~~'*)
        if [ "$IN_FENCE" -eq 1 ]; then IN_FENCE=0; else IN_FENCE=1; fi
        continue
        ;;
    esac
    [ "$IN_FENCE" -eq 1 ] && continue

    case "$line" in
      '#'*)
        # Extraction de titre pure bash (Mission 127), meme technique deja
        # utilisee pour LTRIM ci-dessus : ${var%%pattern} isole le plus long
        # prefixe compose uniquement du caractere vise (# puis espace),
        # ${var#"$prefixe"} le retire -- equivalent a sed -E 's/^#+[[:space:]]*//'
        # sans lancer de processus par ligne de titre.
        SECTION="$line"
        HASHRUN="${SECTION%%[!#]*}"
        SECTION="${SECTION#"$HASHRUN"}"
        SECTION="${SECTION#"${SECTION%%[![:space:]]*}"}"
        continue
        ;;
    esac

    # Ne traite que les lignes portant au moins un span backtick.
    case "$line" in
      *'`'*'`'*) : ;;
      *) continue ;;
    esac

    REST="$line"
    while :; do
      case "$REST" in
        *'`'*'`'*) : ;;
        *) break ;;
      esac
      BEFORE="${REST%%\`*}"
      AFTER1="${REST#*\`}"
      TOKEN="${AFTER1%%\`*}"
      AFTER2="${AFTER1#*\`}"
      REST="$AFTER2"

      case "$TOKEN" in
        *' '*|*$'\t'*) continue ;;
        *'{{'*|*'}}'*) continue ;;
        *'<'*|*'>'*) continue ;;
        '$'*) continue ;;
        '-'*) continue ;;
      esac

      names_a_file "$TOKEN" || { IGNORED_DIR=$((IGNORED_DIR + 1)); continue; }

      CHECKED=$((CHECKED + 1))

      case "$AFTER2" in
        ' (supprimé)'*|' (supprimé, Mission '*)
          ACCEPTED_MARKED=$((ACCEPTED_MARKED + 1))
          continue
          ;;
      esac

      if ! resolve_token "$TOKEN" "$SOURCE_DIR"; then
        FAIL=1
        DEFECT_COUNT=$((DEFECT_COUNT + 1))
        echo "CHEMIN-AFFIRME-MORT : $rel:$LINE_NO [$SECTION] jeton \`$TOKEN\` introuvable sous les racines candidates" >&2
      fi
    done
  done < "$FULL"
done <<EOF_PERIMETER
$PERIMETER_FILES
EOF_PERIMETER

PERIMETER_COUNT="$(printf '%s\n' "$PERIMETER_FILES" | grep -c .)"

echo "Comptes : fichiers du périmètre=$PERIMETER_COUNT jetons-fichier examinés=$CHECKED dossiers nus ignorés=$IGNORED_DIR marqués acceptés=$ACCEPTED_MARKED défauts=$DEFECT_COUNT"

if [ "$FAIL" -ne 0 ]; then
  echo "REFUS : $DEFECT_COUNT chemin(s) affirmé(s) introuvable(s)." >&2
  exit 1
fi

exit 0
