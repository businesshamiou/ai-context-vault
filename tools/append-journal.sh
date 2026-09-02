#!/usr/bin/env bash
# Ajoute une ligne horodatee en fin de journal d'un projet.
# N'ouvre jamais le fichier en lecture ; ne reecrit jamais une ligne existante.
# Cree le fichier et son dossier s'ils n'existent pas.
#
# usage: append-journal.sh <chemin-projet> "<texte>"
#
# --- Conception fail-open du cablage remember (Mission 122, Gate 2) --------------
# Ecrite avant tout code de cablage, conformement a la Mission. Apres l'ecriture
# reussie de la ligne au journal, le script tente d'alimenter une banque memoire
# Mnemosyne (remember) -- mais :
#   1. Le journal est ecrit AVANT toute tentative de remember (deja fait plus bas
#      dans ce script) : un remember rate ne retarde ni n'empeche jamais la ligne.
#   2. Toute condition anormale -- fichier de config projet absent ou incomplet,
#      binaire mnemosyne introuvable, commande en echec ou trop lente -- emet UN
#      avertissement sur stderr et continue. Jamais de "exit" dans ce chemin.
#   3. Le code de sortie du script reste TOUJOURS celui d'avant ce cablage : le
#      bloc remember s'execute apres l'ecriture reussie, sans jamais modifier ni
#      lire le code de sortie de la commande d'ecriture -- garanti par construction
#      (fonction shell qui se termine toujours par "return 0", jamais appelee avec
#      "|| exit" ni "&&").
#   4. Aucun chemin absolu machine, aucun nom de banque code en dur dans ce script
#      du Vault : les deux viennent d'un fichier de config **du projet**
#      (<racine-git-du-projet>/.mnemosyne.env), jamais ecrit ni lu comme executable
#      (parse ligne a ligne, jamais "source"). Fichier absent = remember desactive,
#      comportement identique a avant ce cablage (Validation 5, Mission 122).
#   5. Timeout court (10 s) sur l'appel CLI : un Mnemosyne qui pend ne doit jamais
#      faire attendre un appelant du journal.
#
# usage interne : appelee une seule fois, apres l'ecriture du journal ; ne prend
# aucun argument, lit $PROJECT et $TEXT deja valides ci-dessus.
remember_fail_open() {
  local project_git_root config_file bank data_dir mnemosyne_bin line

  project_git_root="$(git -C "$PROJECT" rev-parse --show-toplevel 2>/dev/null)" || return 0
  config_file="$project_git_root/.mnemosyne.env"
  [ -f "$config_file" ] || return 0

  bank=""
  data_dir=""
  mnemosyne_bin=""
  while IFS= read -r line; do
    case "$line" in
      MNEMOSYNE_BANK=*) bank="${line#MNEMOSYNE_BANK=}" ;;
      MNEMOSYNE_DATA_DIR=*) data_dir="${line#MNEMOSYNE_DATA_DIR=}" ;;
      MNEMOSYNE_BIN=*) mnemosyne_bin="${line#MNEMOSYNE_BIN=}" ;;
    esac
  done < "$config_file"

  if [ -z "$bank" ] || [ -z "$data_dir" ] || [ -z "$mnemosyne_bin" ]; then
    echo "AVERTISSEMENT append-journal.sh : configuration Mnemosyne incomplete ($config_file), remember ignore." >&2
    return 0
  fi

  case "$data_dir" in
    /*|[A-Za-z]:*) : ;;
    *) data_dir="$project_git_root/$data_dir" ;;
  esac
  case "$mnemosyne_bin" in
    /*|[A-Za-z]:*) : ;;
    *) mnemosyne_bin="$project_git_root/$mnemosyne_bin" ;;
  esac

  if [ ! -x "$mnemosyne_bin" ]; then
    echo "AVERTISSEMENT append-journal.sh : binaire mnemosyne introuvable ($mnemosyne_bin), remember ignore." >&2
    return 0
  fi

  if ! MNEMOSYNE_DATA_DIR="$data_dir" MNEMOSYNE_BANK="$bank" \
       MNEMOSYNE_LLM_ENABLED=false MNEMOSYNE_HOST_LLM_ENABLED=false \
       MNEMOSYNE_EMBEDDINGS_OFF=true MNEMOSYNE_NO_EMBEDDINGS=true \
       timeout 10 "$mnemosyne_bin" store "$TEXT" append-journal 2 \
       >/dev/null 2>&1
  then
    echo "AVERTISSEMENT append-journal.sh : mnemosyne store en echec ou trop lent, remember ignore (journal deja ecrit normalement)." >&2
  fi
  return 0
}

set -u

PROJECT="${1:-}"
TEXT="${2:-}"

if [ -z "$PROJECT" ] || [ -z "$TEXT" ]; then
  echo "usage: append-journal.sh <chemin-projet> \"<texte>\"" >&2
  exit 1
fi

# --- Butee 300 caracteres (Decision 191407, Mission 123) ------------------------
# Fail-closed, avant toute ecriture : le texte fourni par l'appelant (hors
# horodatage, prefixe par ce script lui-meme plus bas) ne doit jamais depasser
# MAX_LINE_CHARS. Comptage en caracteres (wc -m), pas en octets -- coherent
# avec la convention deja mesuree aux Missions 121/122 sur la ligne STATE:.
# Refus sans rien ecrire : ni journal, ni Mnemosyne (le remember ne peut pas
# s'executer avant l'ecriture du journal, cf. conception fail-open ci-dessus).
MAX_LINE_CHARS=300

TEXT_LEN="$(printf '%s' "$TEXT" | wc -m)"
if [ "$TEXT_LEN" -gt "$MAX_LINE_CHARS" ]; then
  echo "REFUS append-journal.sh : ligne de $TEXT_LEN caracteres, plafond $MAX_LINE_CHARS (Decision 191407). Rien ecrit (journal, Mnemosyne)." >&2
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
APPEND_STATUS=$?

# Remember fail-open (Mission 122) : uniquement apres l'ecriture ci-dessus,
# jamais avant. Voir la conception en tete de script (Gate 2). Le code de
# sortie du script reste celui de l'ecriture du journal, jamais celui de
# remember_fail_open (qui retourne toujours 0) -- capture explicite pour ne
# pas laisser la derniere commande du fichier decider du code de sortie.
remember_fail_open

exit "$APPEND_STATUS"
