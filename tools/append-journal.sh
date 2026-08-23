#!/usr/bin/env bash
# Ajoute une ligne horodatee en fin de journal d'un projet.
# N'ouvre jamais le fichier en lecture ; ne reecrit jamais une ligne existante.
# Cree le fichier et son dossier s'ils n'existent pas.
#
# usage: append-journal.sh <chemin-projet> "<texte>"

set -u

PROJECT="${1:-}"
TEXT="${2:-}"

if [ -z "$PROJECT" ] || [ -z "$TEXT" ]; then
  echo "usage: append-journal.sh <chemin-projet> \"<texte>\"" >&2
  exit 1
fi

STATE_DIR="$PROJECT/state"
JOURNAL="$STATE_DIR/journal.md"

mkdir -p "$STATE_DIR"

if [ ! -f "$JOURNAL" ]; then
  printf '# Journal — %s\n\nJournal en ajout seul. Genere/alimente par tools/append-journal.sh, jamais edite a la main.\n\n' "$(basename "$PROJECT")" > "$JOURNAL"
fi

TS="$(date +"%Y-%m-%dT%H:%M:%S%:z")"
printf '%s %s\n' "$TS" "$TEXT" >> "$JOURNAL"
