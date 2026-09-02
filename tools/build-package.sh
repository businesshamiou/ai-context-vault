#!/usr/bin/env bash
# Construit le paquet de distribution du Vault depuis distribution-manifest.txt
# (Mission 115). Le manifeste est la seule source du contenu : rien n'est
# decide ici. Fail-closed (DECISION-193624) : tout echec -> exit 1, message
# d'une ligne + verbatim sur stderr, rien laisse dans dist/. N'ecrit jamais
# dans vault/ ni workshop-build/ : zone temporaire hors depots, puis dist/.
#
# Outil de compression : PowerShell Compress-Archive (mesure : GNU tar de ce
# poste n'a pas de format zip natif, -a -cf produit un tar nomme .zip que
# unzip refuse -- Mission 115, precondition 5, arbitrage Owner 2026-09-01).
# Produit un zip standard, gere nativement les chemins a espaces (arguments
# passes par chemin, pas de decoupage shell).
#
# usage: build-package.sh

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VAULT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_ROOT="$(cd "$VAULT_ROOT/.." && pwd)"
DIST_DIR="$WORKSPACE_ROOT/dist"
MANIFEST="$VAULT_ROOT/distribution-manifest.txt"
TAB="$(printf '\t')"

TMP_DIR=""
fail() {
  echo "REFUS build-package.sh : $1" >&2
  if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
  fi
  exit 1
}

cd "$VAULT_ROOT" || fail "impossible d'entrer dans $VAULT_ROOT"

# --- (1) arbre propre ---
DIRTY="$(git status --porcelain)"
if [ -n "$DIRTY" ]; then
  fail "arbre non propre, paquet non reproductible :
$DIRTY"
fi

# --- (2) HEAD = origin/main, apres fetch ---
git fetch origin >/dev/null 2>&1 || fail "git fetch origin a echoue"
HEAD_SHA="$(git rev-parse HEAD)"
ORIGIN_SHA="$(git rev-parse origin/main)"
if [ "$HEAD_SHA" != "$ORIGIN_SHA" ]; then
  fail "HEAD ($HEAD_SHA) != origin/main ($ORIGIN_SHA) -- un paquet construit depuis un commit local non pousse n'est reproductible par personne"
fi

[ -f "$MANIFEST" ] || fail "manifeste introuvable : $MANIFEST"

# --- (3) lecture du manifeste : verdicts valides, 0 doublon, chaque ligne resout dans git ls-files ---
declare -A SEEN=()
declare -A VERDICT=()
DUP_LINES=""
DUP=0
BAD_VERDICT_LINES=""
BAD_VERDICT=0
while IFS="$TAB" read -r MPATH MVERDICT; do
  [ -z "$MPATH" ] && continue
  if [ -n "${SEEN[$MPATH]+x}" ]; then
    DUP=$((DUP + 1))
    DUP_LINES="$DUP_LINES
  doublon : $MPATH"
  fi
  SEEN["$MPATH"]=1
  case "$MVERDICT" in
    DISTRIBUABLE | INTERNE) : ;;
    *)
      BAD_VERDICT=$((BAD_VERDICT + 1))
      BAD_VERDICT_LINES="$BAD_VERDICT_LINES
  verdict invalide : $MPATH -> $MVERDICT"
      ;;
  esac
  VERDICT["$MPATH"]="$MVERDICT"
done < "$MANIFEST"
[ "$DUP" -eq 0 ] || fail "$DUP doublon(s) dans le manifeste :$DUP_LINES"
[ "$BAD_VERDICT" -eq 0 ] || fail "$BAD_VERDICT verdict(s) hors {DISTRIBUABLE,INTERNE} :$BAD_VERDICT_LINES"

GHOST=0
GHOST_LINES=""
for MPATH in "${!VERDICT[@]}"; do
  if ! git ls-files --error-unmatch -- "$MPATH" >/dev/null 2>&1; then
    GHOST=$((GHOST + 1))
    GHOST_LINES="$GHOST_LINES
  fantome (manifeste, absent de git ls-files) : $MPATH"
  fi
done
[ "$GHOST" -eq 0 ] || fail "$GHOST chemin(s) du manifeste absent(s) de git ls-files :$GHOST_LINES"

# --- (4) tout fichier suivi manque au manifeste (meme controle que le gardien) ---
MISSING=0
MISSING_LINES=""
while IFS= read -r GPATH; do
  if [ -z "${VERDICT[$GPATH]+x}" ]; then
    MISSING=$((MISSING + 1))
    MISSING_LINES="$MISSING_LINES
  absent du manifeste : $GPATH"
  fi
done < <(git ls-files)
[ "$MISSING" -eq 0 ] || fail "$MISSING fichier(s) suivi(s) absent(s) du manifeste :$MISSING_LINES"

N_DISTRIBUABLE=0
N_INTERNE=0
for MPATH in "${!VERDICT[@]}"; do
  if [ "${VERDICT[$MPATH]}" = "DISTRIBUABLE" ]; then
    N_DISTRIBUABLE=$((N_DISTRIBUABLE + 1))
  else
    N_INTERNE=$((N_INTERNE + 1))
  fi
done

# --- (5) zone temporaire hors depots, copie des DISTRIBUABLE, chemins preserves ---
mkdir -p "$WORKSPACE_ROOT" || fail "workspace introuvable : $WORKSPACE_ROOT"
TMP_DIR="$(mktemp -d "$WORKSPACE_ROOT/.package-tmp-XXXXXX")" || fail "mktemp a echoue"
PKG_DIR="$TMP_DIR/vault"
mkdir -p "$PKG_DIR" || fail "mkdir $PKG_DIR a echoue"

N_COPIED=0
while IFS="$TAB" read -r MPATH MVERDICT; do
  [ -z "$MPATH" ] && continue
  [ "$MVERDICT" = "DISTRIBUABLE" ] || continue
  SRC="$VAULT_ROOT/$MPATH"
  DEST="$PKG_DIR/$MPATH"
  DEST_DIR="$(dirname "$DEST")"
  mkdir -p "$DEST_DIR" || fail "mkdir $DEST_DIR a echoue (fichier : $MPATH)"
  cp -p "$SRC" "$DEST" || fail "copie echouee : $MPATH"
  N_COPIED=$((N_COPIED + 1))
done < "$MANIFEST"
[ "$N_COPIED" -eq "$N_DISTRIBUABLE" ] || fail "copie incomplete : $N_COPIED/$N_DISTRIBUABLE fichiers DISTRIBUABLE copies"

# --- (6a) LICENSES.md : Vault + une ligne par skill, refuse si license: absent ---
LICENSES_FILE="$PKG_DIR/LICENSES.md"
{
  echo "# LICENSES"
  echo ""
  echo "Genere automatiquement par tools/build-package.sh depuis distribution-manifest.txt. Ne pas editer a la main."
  echo ""
  echo "## Vault"
  echo ""
  echo "Le corpus du Vault (regles, decisions, gabarits, outils, skills fabriques) est distribue sous licence MIT. Voir LICENSE a la racine de ce paquet."
  echo ""
  echo "## Skills"
  echo ""
  echo "La bibliotheque de skills adoptee (skills/external/) porte sa propre licence par skill, citee ci-dessous depuis le champ \`license:\` de chaque SKILL.md ; voir aussi LICENSE-mattpocock-skills.txt pour les skills issus de github.com/mattpocock/skills."
  echo ""
} > "$LICENSES_FILE"

NO_LICENSE=0
NO_LICENSE_LINES=""
while IFS= read -r -d '' SKILL_MD; do
  REL="${SKILL_MD#"$VAULT_ROOT"/}"
  case "$REL" in
    skills/*) : ;;
    *) continue ;;
  esac
  LIC="$(sed -n -E 's/^license:[[:space:]]*"?([^"]*)"?[[:space:]]*$/\1/p' "$SKILL_MD" | head -n 1)"
  if [ -z "$LIC" ]; then
    NO_LICENSE=$((NO_LICENSE + 1))
    NO_LICENSE_LINES="$NO_LICENSE_LINES
  sans license: $REL"
    continue
  fi
  NAME="$(basename "$(dirname "$SKILL_MD")")"
  echo "- \`$NAME\` -- $LIC -- \`$REL\`" >> "$LICENSES_FILE"
done < <(find "$VAULT_ROOT/skills" -type f -name 'SKILL.md' -print0 | sort -z)
[ "$NO_LICENSE" -eq 0 ] || fail "$NO_LICENSE SKILL.md sans champ license: :$NO_LICENSE_LINES"

# --- (6b) PACKAGE-MANIFEST.txt ---
PKG_MANIFEST="$PKG_DIR/PACKAGE-MANIFEST.txt"
{
  echo "PACKAGE-MANIFEST"
  echo "commit: $HEAD_SHA"
  echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "distribuable: $N_DISTRIBUABLE"
  echo "interne (exclu du paquet): $N_INTERNE"
  echo ""
  while IFS="$TAB" read -r MPATH MVERDICT; do
    [ "$MVERDICT" = "DISTRIBUABLE" ] && printf '%s\n' "$MPATH"
  done < "$MANIFEST"
} > "$PKG_MANIFEST"

# --- (6c) SHA256SUMS.txt : tous les fichiers du paquet, generes compris, sauf lui-meme ---
SUMS_FILE="$PKG_DIR/SHA256SUMS.txt"
: > "$SUMS_FILE"
while IFS= read -r -d '' F; do
  REL="${F#"$PKG_DIR"/}"
  (cd "$PKG_DIR" && sha256sum -- "$REL") >> "$SUMS_FILE"
done < <(find "$PKG_DIR" -type f ! -name 'SHA256SUMS.txt' -print0 | sort -z)

# --- (7) zip, racine "vault/" dans l'archive ---
mkdir -p "$DIST_DIR" || fail "mkdir $DIST_DIR a echoue"
TS="$(date +%Y%m%d-%H%M%S)"
SHA7="${HEAD_SHA:0:7}"
ZIP_NAME="vault-${TS}-${SHA7}.zip"
ZIP_PATH="$DIST_DIR/$ZIP_NAME"
[ -e "$ZIP_PATH" ] && fail "le zip cible existe deja : $ZIP_PATH"

WIN_SRC="$(cygpath -w "$PKG_DIR")"
WIN_ZIP="$(cygpath -w "$ZIP_PATH")"
PS_OUT="$(powershell.exe -NoProfile -Command "Compress-Archive -Path '$WIN_SRC' -DestinationPath '$WIN_ZIP' -CompressionLevel Optimal" 2>&1)"
PS_EXIT=$?
if [ "$PS_EXIT" -ne 0 ] || [ ! -f "$ZIP_PATH" ]; then
  fail "Compress-Archive a echoue (exit=$PS_EXIT) :
$PS_OUT"
fi

ZIP_SHA="$(sha256sum -- "$ZIP_PATH" | cut -d' ' -f1)"
N_FILES="$(find "$PKG_DIR" -type f | wc -l)"

rm -rf "$TMP_DIR"

# --- (8) sortie ---
echo "Paquet : $ZIP_PATH · fichiers : $N_FILES · SHA-256 : $ZIP_SHA"
exit 0
