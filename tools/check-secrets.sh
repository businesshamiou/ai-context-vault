#!/usr/bin/env bash
# Controle de secrets sur les lignes ajoutees d un diff stage.
# Shell portable : aucune dependance a Python.
# Le refus est la position par defaut : toute condition anormale bloque.

set -u

# Garde Git (Mission 125) : hors d'un depot, "git rev-parse" echoue et rend
# une chaine vide sans arreter le script -- tout chemin batu sur $VAULT_ROOT
# devenait alors absolu, raciné a "/", et le refus qui suivait (fichier de
# motifs introuvable) etait un accident, pas une garde. Refus explicite ici.
VAULT_ROOT="$(git rev-parse --show-toplevel)" || {
  echo "REFUS : hors d'un depot Git : gardien non executable." >&2
  exit 1
}
PATTERNS_FILE="$VAULT_ROOT/rules/patterns/secret-patterns.txt"

if [ ! -f "$PATTERNS_FILE" ]; then
  echo "REFUS : fichier de motifs introuvable : $PATTERNS_FILE" >&2
  echo "Le controle ne peut pas verifier, il refuse." >&2
  exit 1
fi

# --- 1. Noms de fichiers interdits ---
FORBIDDEN_NAMES='(^|/)\.env($|\.)|\.(key|pem|pfx|p12|crt|cer|der|jks|keystore)$|(^|/)(secrets?|credentials?)(/|$)|\.(sql|dump|sqlite|db|mdb)$'

STAGED="$(git diff --cached --name-only --diff-filter=ACM)"

if [ -n "$STAGED" ]; then
  BAD_NAMES="$(printf '%s\n' "$STAGED" | grep -E "$FORBIDDEN_NAMES" || true)"
  # .env.example est la seule exception : un modele sans valeur.
  BAD_NAMES="$(printf '%s\n' "$BAD_NAMES" | grep -v '\.env\.example$' || true)"
  if [ -n "$BAD_NAMES" ]; then
    echo "REFUS : fichier(s) au nom interdit dans le staging :" >&2
    printf '  %s\n' $BAD_NAMES >&2
    exit 1
  fi
fi

# --- 2. Motifs dans les lignes ajoutees ---
ADDED="$(git diff --cached -U0 --diff-filter=ACM | grep -E '^\+' | grep -Ev '^\+\+\+' || true)"

if [ -z "$ADDED" ]; then
  exit 0
fi

FOUND=0
while IFS= read -r pattern; do
  case "$pattern" in
    ''|'#'*) continue ;;
  esac
  MATCH="$(printf '%s\n' "$ADDED" | grep -E -- "$pattern" || true)"
  if [ -n "$MATCH" ]; then
    echo "REFUS : motif de secret detecte." >&2
    echo "  motif : $pattern" >&2
    echo "  (valeur non affichee)" >&2
    FOUND=1
  fi
done < "$PATTERNS_FILE"

if [ "$FOUND" -ne 0 ]; then
  echo "" >&2
  echo "Retire la valeur du fichier, place-la dans .env (non suivi)," >&2
  echo "et documente la cle attendue dans .env.example." >&2
  echo "Ne contourne pas ce controle." >&2
  exit 1
fi

exit 0
