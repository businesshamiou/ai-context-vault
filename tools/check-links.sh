#!/usr/bin/env bash
# Controle de liens sur les fichiers .md stages.
# Shell portable : aucune dependance a Python, meme structure que check-secrets.sh.
# Le refus est la position par defaut : toute condition anormale bloque.

set -u

VAULT_ROOT="$(git rev-parse --show-toplevel)"

STAGED="$(git diff --cached --name-only --diff-filter=AM -- '*.md' || true)"

if [ -z "$STAGED" ]; then
  exit 0
fi

BLOCK=0

while IFS= read -r file; do
  [ -z "$file" ] && continue
  case "$file" in
    graphify-out/*) continue ;;
  esac

  FULLPATH="$VAULT_ROOT/$file"
  [ -f "$FULLPATH" ] || continue

  DIR="$(dirname "$FULLPATH")"

  # --- 1. Section "## Liens" obligatoire ---
  if ! grep -qE '^## Liens[[:space:]]*$' "$FULLPATH"; then
    echo "LIENS: section manquante: $file" >&2
    BLOCK=1
  fi

  # --- 2/3. Liens relatifs : cible resolue, ou avertissement si aucun lien interne ---
  HAS_INTERNAL=0
  LINE_NO=0

  while IFS= read -r line || [ -n "$line" ]; do
    LINE_NO=$((LINE_NO + 1))

    case "$line" in
      *'](./'*|*'](../'*) : ;;
      *) continue ;;
    esac

    HORS=0
    case "$line" in
      *'(hors Vault)'*|*'(hors workshop-build)'*) HORS=1 ;;
    esac

    TARGETS="$(printf '%s' "$line" | grep -oE '\]\(\.{1,2}/[^)]*\)' | sed -E 's/^\]\((.*)\)$/\1/')"
    [ -z "$TARGETS" ] && continue

    while IFS= read -r TARGET; do
      [ -z "$TARGET" ] && continue
      case "$TARGET" in
        *.md) : ;;
        *) continue ;;
      esac

      if [ "$HORS" -eq 1 ]; then
        continue
      fi

      TARGET_PATH="$DIR/$TARGET"
      if command -v realpath >/dev/null 2>&1; then
        RESOLVED="$(realpath -m "$TARGET_PATH" 2>/dev/null)"
      else
        RDIR="$(cd "$(dirname "$TARGET_PATH")" 2>/dev/null && pwd)"
        RESOLVED="${RDIR:+$RDIR/$(basename "$TARGET_PATH")}"
      fi

      if [ -z "$RESOLVED" ] || [ ! -f "$RESOLVED" ]; then
        echo "LIENS: cible introuvable: $file:$LINE_NO -> $TARGET" >&2
        BLOCK=1
      else
        HAS_INTERNAL=1
      fi
    done <<TARGETS_EOF
$TARGETS
TARGETS_EOF
  done < "$FULLPATH"

  if [ "$HAS_INTERNAL" -eq 0 ]; then
    echo "LIENS: avertissement, aucun lien interne: $file" >&2
  fi
done <<STAGED_EOF
$STAGED
STAGED_EOF

if [ "$BLOCK" -ne 0 ]; then
  exit 1
fi

exit 0
