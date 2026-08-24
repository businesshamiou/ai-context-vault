#!/usr/bin/env bash
# Regenere <projet>/state/STATE.md a partir du journal, de l'etat Git et du
# listing des fichiers. Fiche generee : ne jamais l'editer a la main.
#
# Convention de tags reconnue dans les lignes du journal (texte apres l'horodatage) :
#   ETAT:<texte>     -> etat courant (derniere occurrence retenue)
#   PROCHAIN:<texte> -> prochaine action (derniere occurrence retenue)
#   OUVERT:<texte>   -> porte ouverte (toutes les occurrences listees)
#   REPRISE:<texte>  -> note de reprise ; doit etre la derniere ligne du journal
# Depuis Mission 038, double reconnaissance : STATE:/NEXT:/OPEN:/RESUME: (anglais) en plus des tags francais ci-dessus.
# Une ligne sans tag reconnu n'alimente aucune rubrique ci-dessus.
#
# usage: build-state.sh <chemin-projet>

set -u

PROJECT="${1:-}"
if [ -z "$PROJECT" ]; then
  echo "usage: build-state.sh <chemin-projet>" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VAULT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$PROJECT" && pwd)"
STATE_DIR="$PROJECT_ROOT/state"
JOURNAL="$STATE_DIR/journal.md"
STATE_FILE="$STATE_DIR/STATE.md"
CONTRACT_TEMPLATE="$VAULT_ROOT/templates/pilot-contract-template.md"

# --- 0. Contrat du Pilot, recopie depuis le gabarit, jamais redige ici ---
# Plafond arbitre : exactement sept lignes (Mission 029). Echec explicite,
# fiche non ecrite, si le gabarit s'ecarte de ce plafond.
CONTRACT_LINES="$(awk '
  /<!-- CONTRACT:BEGIN -->/ { f=1; next }
  /<!-- CONTRACT:END -->/   { f=0 }
  f && NF { print }
' "$CONTRACT_TEMPLATE" 2>/dev/null)"

CONTRACT_COUNT=0
if [ -n "$CONTRACT_LINES" ]; then
  CONTRACT_COUNT="$(printf '%s\n' "$CONTRACT_LINES" | wc -l)"
fi

if [ ! -f "$CONTRACT_TEMPLATE" ]; then
  echo "ERREUR build-state.sh : gabarit de contrat introuvable ($CONTRACT_TEMPLATE). Fiche d'état non générée." >&2
  exit 1
fi

if [ "$CONTRACT_COUNT" -ne 7 ]; then
  echo "ERREUR build-state.sh : le gabarit de contrat ($CONTRACT_TEMPLATE) porte $CONTRACT_COUNT ligne(s) entre CONTRACT:BEGIN et CONTRACT:END, le plafond arbitré est de sept lignes exactement. Fiche d'état non générée." >&2
  exit 1
fi

mkdir -p "$STATE_DIR"

get_field() {
  awk -v f="$2" '
    NR==1 && $0=="---" { infm=1; next }
    infm && $0=="---" { exit }
    infm && $0 ~ "^"f":" {
      sub("^"f":[[:space:]]*", "")
      gsub(/^"|"$/, "")
      print
      exit
    }
  ' "$1" 2>/dev/null
}

# --- 1. Lecture des balises du journal ---
LAST_TS=""
LAST_LINE=""
ETAT="Aucune entree ETAT: dans le journal."
PROCHAIN="Aucune entree PROCHAIN: dans le journal."
OUVERTES="Aucune."
REPRISE_STATUS="Le journal ne se termine pas par une note de reprise (REPRISE:) — rien reconstitue."

if [ -f "$JOURNAL" ]; then
  DATED="$(grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}T' "$JOURNAL" || true)"
  if [ -n "$DATED" ]; then
    LAST_LINE="$(printf '%s\n' "$DATED" | tail -n 1)"
    LAST_TS="$(printf '%s' "$LAST_LINE" | awk '{print $1}')"

    E="$(printf '%s\n' "$DATED" | grep -E 'ETAT:|STATE:' | tail -n 1 | sed -E 's/^.*(ETAT|STATE):[[:space:]]*//')"
    [ -n "$E" ] && ETAT="$E"

    P="$(printf '%s\n' "$DATED" | grep -E 'PROCHAIN:|NEXT:' | tail -n 1 | sed -E 's/^.*(PROCHAIN|NEXT):[[:space:]]*//')"
    [ -n "$P" ] && PROCHAIN="$P"

    O="$(printf '%s\n' "$DATED" | grep -E 'OUVERT:|OPEN:' | sed -E 's/^.*(OUVERT|OPEN):[[:space:]]*//')"
    if [ -n "$O" ]; then
      OUVERTES="$(printf '%s\n' "$O" | sed 's/^/- /')"
    fi

    case "$LAST_LINE" in
      *'REPRISE:'*|*'RESUME:'*) REPRISE_STATUS="Note de reprise en fin de journal : $(printf '%s' "$LAST_LINE" | sed -E 's/^.*(REPRISE|RESUME):[[:space:]]*//')" ;;
    esac
  fi
fi

# --- 2. Catalogue des documents recents (mtime desc, limite 15) ---
RECENTS="$(find "$PROJECT_ROOT" -type f -name '*.md' -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -n 15 | cut -d' ' -f2-)"

DOC_LIST=""
if [ -n "$RECENTS" ]; then
  while IFS= read -r F; do
    [ -z "$F" ] && continue
    REL="$(realpath --relative-to="$PROJECT_ROOT" "$F")"
    T="$(get_field "$F" title)"
    [ -z "$T" ] && T="(sans titre)"
    DOC_LIST="$DOC_LIST- \`$REL\` — $T
"
  done <<EOF
$RECENTS
EOF
else
  DOC_LIST="Aucun document .md trouve."
fi

# --- 3. Etat des depots ---
VAULT_STATUS="$(git -C "$VAULT_ROOT" status -sb 2>/dev/null || echo "non mesurable")"
PROJECT_GIT_ROOT="$(git -C "$PROJECT_ROOT" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -n "$PROJECT_GIT_ROOT" ]; then
  PROJECT_STATUS="$(git -C "$PROJECT_GIT_ROOT" status -sb 2>/dev/null)"
else
  PROJECT_STATUS="non mesurable (pas un depot Git)"
fi

# --- 4. Ecriture ---
{
  echo "---"
  echo "type: state"
  echo "title: \"Fiche d'état — $(basename "$PROJECT_ROOT")\""
  echo "description: \"Fiche générée automatiquement par tools/build-state.sh — catalogue, pas un résumé.\""
  echo "status: GENERATED"
  echo "generated_by: tools/build-state.sh"
  echo "---"
  echo ""
  echo "# FICHE D'ÉTAT — $(basename "$PROJECT_ROOT")"
  echo ""
  echo "> Générée automatiquement par \`build-state.sh\`. Ne pas éditer à la main."
  echo "> Source : \`state/journal.md\` (dernière entrée : ${LAST_TS:-aucune})."
  echo ""
  echo "## Contrat du Pilot"
  echo ""
  printf '%s\n' "$CONTRACT_LINES"
  echo ""
  echo "## État courant"
  echo ""
  echo "$ETAT"
  echo ""
  echo "## Prochaine action"
  echo ""
  echo "$PROCHAIN"
  echo ""
  echo "## Portes ouvertes"
  echo ""
  echo "$OUVERTES"
  echo ""
  echo "## Documents récents"
  echo ""
  printf '%s' "$DOC_LIST"
  echo ""
  echo "## État des dépôts"
  echo ""
  echo "**vault :**"
  echo '```'
  echo "$VAULT_STATUS"
  echo '```'
  echo ""
  echo "**$(basename "${PROJECT_GIT_ROOT:-$PROJECT_ROOT}") :**"
  echo '```'
  echo "$PROJECT_STATUS"
  echo '```'
  echo ""
  echo "## Reprise"
  echo ""
  echo "$REPRISE_STATUS"
  echo ""
  echo "## Liens"
  echo ""
  echo "- \`prescrit par\` — [Lot A — journal, fiche d'état, index générés, recherche par contenu et fichier marqueur](../missions/MISSION-2026-08-23-122712-027-state-journal-indexes-search-and-marker.md)"
} > "$STATE_FILE"
