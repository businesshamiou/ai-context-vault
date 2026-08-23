#!/usr/bin/env bash
# Recherche par contenu dans les fichiers .md sous une racine.
# Renvoie les lignes trouvees, jamais les fichiers : un resultat par ligne,
# format "chemin:numero-de-ligne:texte".
#
# usage: find-in-vault.sh [--root <dir>] [--limit N] [--frontmatter-only] <motif>

set -u

ROOT="."
LIMIT=50
FM_ONLY=0
PATTERN=""
HAVE_PATTERN=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --root)
      ROOT="${2:-.}"
      shift 2
      ;;
    --limit)
      LIMIT="${2:-50}"
      shift 2
      ;;
    --frontmatter-only)
      FM_ONLY=1
      shift
      ;;
    --)
      shift
      if [ "$#" -gt 0 ]; then PATTERN="$1"; HAVE_PATTERN=1; shift; fi
      ;;
    *)
      PATTERN="$1"
      HAVE_PATTERN=1
      shift
      ;;
  esac
done

if [ "$HAVE_PATTERN" -ne 1 ] || [ -z "$PATTERN" ]; then
  echo "usage: find-in-vault.sh [--root <dir>] [--limit N] [--frontmatter-only] <motif>" >&2
  exit 1
fi

if [ ! -d "$ROOT" ]; then
  echo "REFUS : racine introuvable : $ROOT" >&2
  exit 1
fi

EXCLUDE_RE='(^|/)(\.git|\.githooks|\.claude|\.codex|graphify-out|node_modules|\.venv|venv|__pycache__)(/|$)'

if [ "$FM_ONLY" -eq 1 ]; then
  # Mode front-matter : les bornes "---" different par fichier (FNR), mais un
  # seul processus awk traite tous les fichiers passes en argument (rapide).
  FILES="$(find "$ROOT" -type f -name '*.md' | grep -vE "$EXCLUDE_RE")"
  if [ -n "$FILES" ]; then
    printf '%s\n' "$FILES" | tr '\n' '\0' | xargs -0 awk -v pat="$PATTERN" '
      FNR==1 { infm=0 }
      FNR==1 && $0=="---" { infm=1; next }
      infm && $0=="---" { infm=0; next }
      infm && $0 ~ pat { print FILENAME ":" FNR ":" $0 }
    ' 2>/dev/null
  fi
else
  grep -rnE --include='*.md' -- "$PATTERN" "$ROOT" 2>/dev/null | grep -vE "$EXCLUDE_RE"
fi | head -n "$LIMIT"
