#!/usr/bin/env bash
# Verifie vault/distribution-manifest.txt contre l'etat reel du depot.
# Lecture seule : ne corrige jamais un defaut trouve, se contente de refuser
# et de le lister. N'est cable sur aucun hook (Mission 073, arbitrage C) --
# execution manuelle uniquement, resultat rapporte par l'appelant.
#
# Refuse (exit 1) si l'une de ces conditions se verifie :
#   1. un fichier de `git ls-files` est absent du manifeste ;
#   2. un chemin du manifeste n'existe plus dans `git ls-files` ;
#   3. un chemin figure deux fois dans le manifeste ;
#   4. un verdict n'est ni DISTRIBUABLE ni INTERNE ;
#   5. un fichier porte `distributable: false` en front-matter alors que le
#      manifeste le classe DISTRIBUABLE, ou l'inverse (`distributable: true`
#      alors que le manifeste le classe INTERNE).
#
# usage: check-distribution-manifest.sh

set -u

VAULT_ROOT="$(git rev-parse --show-toplevel)"
MANIFEST="$VAULT_ROOT/distribution-manifest.txt"

if [ ! -f "$MANIFEST" ]; then
  echo "REFUS : manifeste introuvable : $MANIFEST" >&2
  exit 1
fi

FAIL=0
DISTRIBUABLE_COUNT=0
INTERNE_COUNT=0

TRACKED_FILE="$(mktemp)"
MANIFEST_PATHS_FILE="$(mktemp)"
trap 'rm -f "$TRACKED_FILE" "$MANIFEST_PATHS_FILE"' EXIT

git -C "$VAULT_ROOT" ls-files | sort > "$TRACKED_FILE"
cut -f1 "$MANIFEST" | sort > "$MANIFEST_PATHS_FILE"

# --- 1. fichier suivi absent du manifeste ---
MISSING_FROM_MANIFEST="$(comm -23 "$TRACKED_FILE" "$MANIFEST_PATHS_FILE")"
if [ -n "$MISSING_FROM_MANIFEST" ]; then
  FAIL=1
  echo "ABSENT-DU-MANIFESTE : fichier suivi sans ligne au manifeste :" >&2
  printf '%s\n' "$MISSING_FROM_MANIFEST" | while IFS= read -r f; do
    echo "  $f" >&2
  done
fi

# --- 2. chemin du manifeste qui n'existe plus dans git ls-files ---
STALE_IN_MANIFEST="$(comm -13 "$TRACKED_FILE" "$MANIFEST_PATHS_FILE")"
if [ -n "$STALE_IN_MANIFEST" ]; then
  FAIL=1
  echo "FANTOME-AU-MANIFESTE : chemin du manifeste non suivi par Git :" >&2
  printf '%s\n' "$STALE_IN_MANIFEST" | while IFS= read -r f; do
    echo "  $f" >&2
  done
fi

# --- 3. chemin en double dans le manifeste ---
DUPLICATES="$(cut -f1 "$MANIFEST" | sort | uniq -d)"
if [ -n "$DUPLICATES" ]; then
  FAIL=1
  echo "DOUBLON-AU-MANIFESTE : chemin present plus d'une fois :" >&2
  printf '%s\n' "$DUPLICATES" | while IFS= read -r f; do
    echo "  $f" >&2
  done
fi

# --- 4/5. verdict et coherence distributable: ---
LINE_NO=0
while IFS="$(printf '\t')" read -r REL_PATH VERDICT || [ -n "$REL_PATH" ]; do
  LINE_NO=$((LINE_NO + 1))
  [ -z "$REL_PATH" ] && continue

  case "$VERDICT" in
    DISTRIBUABLE) DISTRIBUABLE_COUNT=$((DISTRIBUABLE_COUNT + 1)) ;;
    INTERNE) INTERNE_COUNT=$((INTERNE_COUNT + 1)) ;;
    *)
      FAIL=1
      echo "VERDICT-INVALIDE : ligne $LINE_NO, $REL_PATH : verdict '$VERDICT' ni DISTRIBUABLE ni INTERNE" >&2
      continue
      ;;
  esac

  FULL="$VAULT_ROOT/$REL_PATH"
  [ -f "$FULL" ] || continue

  FM_DISTRIBUTABLE="$(head -n 20 "$FULL" | grep -m1 -E '^distributable:[[:space:]]*(true|false)[[:space:]]*$' | awk -F': *' '{print $2}' | tr -d '[:space:]')"

  if [ "$FM_DISTRIBUTABLE" = "false" ] && [ "$VERDICT" = "DISTRIBUABLE" ]; then
    FAIL=1
    echo "INCOHERENCE-DISTRIBUTABLE : $REL_PATH porte 'distributable: false' en front-matter mais le manifeste le classe DISTRIBUABLE" >&2
  fi
  if [ "$FM_DISTRIBUTABLE" = "true" ] && [ "$VERDICT" = "INTERNE" ]; then
    FAIL=1
    echo "INCOHERENCE-DISTRIBUTABLE : $REL_PATH porte 'distributable: true' en front-matter mais le manifeste le classe INTERNE" >&2
  fi
done < "$MANIFEST"

echo "Comptes : DISTRIBUABLE=$DISTRIBUABLE_COUNT INTERNE=$INTERNE_COUNT TOTAL=$((DISTRIBUABLE_COUNT + INTERNE_COUNT))"

if [ "$FAIL" -ne 0 ]; then
  echo "REFUS : le manifeste ne passe pas les controles ci-dessus." >&2
  exit 1
fi

exit 0
