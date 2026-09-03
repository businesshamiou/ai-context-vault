#!/usr/bin/env bash
# Garde-fou de fraicheur des index (Mission 089) : refuse un commit dont un
# .md stage laisse son index.md perime (entree manquante/en trop, status ou
# description desynchronises). Ne regenere jamais, ne modifie jamais rien ;
# lit le format que tools/build-indexes.sh produit (Mission 080), ne le
# redefinit pas -- meme liste de dossiers elagues, meme grammaire de champ.
# Le refus est la position par defaut : toute condition anormale bloque.

set -u

# Garde Git (Mission 125, meme raison qu'a check-secrets.sh) : refus
# explicite hors d'un depot, plutot qu'un $REPO_ROOT vide.
REPO_ROOT="$(git rev-parse --show-toplevel)" || {
  echo "REFUS : hors d'un depot Git : gardien non executable." >&2
  exit 1
}

# Meme enumeration que le find -prune de build-indexes.sh : ces noms de
# dossier, a n'importe quelle profondeur, ne sont jamais un dossier indexe.
PRUNE_NAMES='.git .githooks .claude .codex graphify-out tools patterns node_modules state .venv venv __pycache__'

is_pruned_dir() {
  local d="$1" comp n saved_ifs
  [ "$d" = "." ] && return 1
  saved_ifs="$IFS"
  IFS=/
  set -- $d
  IFS="$saved_ifs"
  for comp in "$@"; do
    for n in $PRUNE_NAMES; do
      [ "$comp" = "$n" ] && return 0
    done
  done
  return 1
}

# Meme grammaire de champ que list_fields() de build-indexes.sh : defaut
# vide, meme retrait des guillemets.
fm_status_desc() {
  awk '
    FNR==1 { infm=0; status=""; description="" }
    FNR==1 && $0=="---" { infm=1; next }
    infm && $0=="---" { infm=0 }
    infm && /^status:/      { v=$0; sub(/^status:[[:space:]]*/,"",v);      gsub(/^"|"$/,"",v); status=v }
    infm && /^description:/ { v=$0; sub(/^description:[[:space:]]*/,"",v); gsub(/^"|"$/,"",v); description=v }
    END { print status "\t" description }
  '
}

fm_type() {
  awk '
    FNR==1 { infm=0; type="" }
    FNR==1 && $0=="---" { infm=1; next }
    infm && $0=="---" { infm=0 }
    infm && /^type:/ { v=$0; sub(/^type:[[:space:]]*/,"",v); gsub(/^"|"$/,"",v); type=v }
    END { t=type; if (t=="") t="inconnu"; print t }
  '
}

contenu_section() {
  awk '
    /^## Contenu[[:space:]]*$/ { on=1; next }
    /^## / { on=0 }
    on { print }
  '
}

# --- Butee 300 caracteres, MISSION-INDEX.md (Decision 191407, Mission 123) -----
# Gardien mesure comme le meilleur candidat existant a etendre (aucun gardien
# ne verifiait MISSION-INDEX.md avant cette Mission -- mesure, pas suppose).
# Non retroactif, sans liste d'exceptions : baseline = dernier numero de
# Mission present dans la table au moment de la gravure de cette regle (122,
# mesure par grep sur le fichier commite avant ce changement). Toute ligne
# d'entree (motif "| `NNN` |" en tete de ligne, determine par lecture directe
# du fichier) dont NNN > baseline est verifiee ; NNN <= baseline passe
# toujours, quelle que soit sa longueur -- aucune ligne existante n'est
# touchee, listee ou exemptee au cas par cas.
MISSION_INDEX_LINE_CAP_BASELINE=122
MISSION_INDEX_PATH="workshop-production/missions/MISSION-INDEX.md"

check_mission_index_line_cap() {
  git cat-file -e ":$MISSION_INDEX_PATH" 2>/dev/null || return 0

  local content line_no=0 line nnn len
  content="$(git show ":$MISSION_INDEX_PATH" 2>/dev/null)"

  while IFS= read -r line; do
    line_no=$((line_no + 1))
    case "$line" in
      '| `'[0-9]*'`'*) : ;;
      *) continue ;;
    esac
    nnn="$(printf '%s' "$line" | sed -E 's/^\| `([0-9]+)`.*/\1/')"
    case "$nnn" in
      ''|*[!0-9]*) continue ;;
    esac
    [ "$nnn" -gt "$MISSION_INDEX_LINE_CAP_BASELINE" ] || continue

    len="$(printf '%s' "$line" | wc -m)"
    if [ "$len" -gt 300 ]; then
      echo "INDEX-LINE-CAP [$MISSION_INDEX_PATH]" >&2
      echo "  Ligne    : $line_no (Mission $nnn)" >&2
      echo "  Longueur : $len caracteres > 300 (Decision 191407)" >&2
      FAIL=1
    fi
  done <<EOF
$content
EOF
}

FAIL=0

report_gap() {
  # $1 = dossier, $2 = ecart, $3 = index_path
  echo "INDEX-FRESHNESS [$1]"
  echo "  Ecart    : $2"
  echo "  Consigne : bash tools/build-indexes.sh <racine> ; git add $3 ; relire git diff --cached"
  FAIL=1
}

check_dir() {
  local dir="$1" prefix
  if [ "$dir" = "." ]; then prefix=""; else prefix="$dir/"; fi

  # Fichiers .md (hors index.md) presents dans ce dossier apres le commit
  # (arbre stage, pas le worktree), profondeur 1 uniquement.
  local disk_files
  disk_files="$(git ls-files -z -- "$dir" 2>/dev/null | tr '\0' '\n' | while IFS= read -r f; do
    [ -z "$f" ] && continue
    rel="${f#"$prefix"}"
    case "$rel" in
      */*) continue ;;
      index.md) continue ;;
      *.md) printf '%s\n' "$rel" ;;
    esac
  done | sort)"

  [ -z "$disk_files" ] && return 0   # pas de .md ici apres le commit : pas un dossier indexe

  local index_path
  if [ "$dir" = "." ]; then index_path="index.md"; else index_path="$dir/index.md"; fi

  if ! git cat-file -e ":$index_path" 2>/dev/null; then
    report_gap "$dir" "dossier indexe sans index.md ($index_path absent de l'arbre stage)" "$index_path"
    return 0
  fi

  local index_content contenu index_names
  index_content="$(git show ":$index_path" 2>/dev/null)"
  contenu="$(printf '%s\n' "$index_content" | contenu_section)"
  index_names="$(printf '%s\n' "$contenu" | sed -n 's/^- `\([^`]*\)`.*/\1/p' | sort)"

  # Entrees en trop : dans l'index, absentes du dossier apres le commit.
  local extra
  extra="$(comm -13 <(printf '%s\n' "$disk_files") <(printf '%s\n' "$index_names") 2>/dev/null)"
  if [ -n "$extra" ]; then
    while IFS= read -r fn; do
      [ -z "$fn" ] && continue
      report_gap "$dir" "entree en trop dans l'index : $fn (absent du dossier apres le commit)" "$index_path"
    done <<EOF
$extra
EOF
  fi

  # Pour chaque fichier reellement present : entree manquante, ou desynchro
  # de status/description.
  while IFS= read -r fn; do
    [ -z "$fn" ] && continue

    if ! printf '%s\n' "$index_names" | grep -qxF "$fn"; then
      report_gap "$dir" "entree manquante dans l'index : $fn" "$index_path"
      continue
    fi

    local fpath="$prefix$fn" fm_content st desc ty
    fpath="${fpath#./}"
    fm_content="$(git show ":$fpath" 2>/dev/null)"
    IFS=$'\t' read -r st desc <<<"$(printf '%s' "$fm_content" | fm_status_desc)"
    ty="$(printf '%s' "$fm_content" | fm_type)"

    # Prefixe d'entree exact, backtick-delimite : sans ambiguite meme si le
    # titre du fichier contient lui-meme un tiret cadratin " — ".
    local entry_prefix="- \`$fn\` — "
    local entry_line="" next_line="" found=0 take_next=0
    while IFS= read -r line; do
      if [ "$take_next" -eq 1 ]; then
        next_line="$line"
        take_next=0
      fi
      case "$line" in
        "$entry_prefix"*)
          entry_line="$line"
          found=1
          take_next=1
          ;;
      esac
    done <<EOF
$contenu
EOF

    [ "$found" -eq 0 ] && continue   # deja signale ci-dessus

    local rest="${entry_line#"$entry_prefix"}"
    # Retire un suffixe MARK (" — REMPLACÉ par ...") : hors perimetre de
    # comparaison (superseded-by), jamais verifie ici.
    rest="${rest%% — REMPLACÉ par *}"

    if [ -n "$st" ]; then
      case "$rest" in
        *" · $st") : ;;
        *) report_gap "$dir" "status desynchronise pour $fn (fichier: \"$st\")" "$index_path" ;;
      esac
    else
      case "$rest" in
        *" · $ty") : ;;
        *) report_gap "$dir" "status desynchronise pour $fn (fichier: aucun status)" "$index_path" ;;
      esac
    fi

    if [ -n "$desc" ]; then
      if [ "$next_line" != "  - $desc" ]; then
        report_gap "$dir" "description desynchronisee pour $fn" "$index_path"
      fi
    else
      case "$next_line" in
        "  - "*) report_gap "$dir" "description desynchronisee pour $fn (fichier: aucune description, index en porte une)" "$index_path" ;;
      esac
    fi
  done <<EOF
$disk_files
EOF
}

# Dossiers a verifier : ceux touches par un .md stage (hors index.md),
# ajouts/modifications/renommages/suppressions.
DIRS=""
while IFS=$'\t' read -r st p1 p2; do
  [ -z "$st" ] && continue
  case "$st" in
    R*|C*) paths="$p1
$p2" ;;
    *) paths="$p1" ;;
  esac
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    case "$p" in *.md) : ;; *) continue ;; esac
    fn="${p##*/}"
    [ "$fn" = "index.md" ] && continue
    d="${p%/*}"
    [ "$d" = "$p" ] && d="."
    is_pruned_dir "$d" && continue
    case " $DIRS " in
      *" $d "*) : ;;
      *) DIRS="$DIRS $d" ;;
    esac
  done <<EOF
$paths
EOF
done < <(cd "$REPO_ROOT" && git diff --cached --name-status -M --diff-filter=ACDMR -- '*.md')

cd "$REPO_ROOT" || exit 1

for d in $DIRS; do
  check_dir "$d"
done

# Butee 300 caracteres sur MISSION-INDEX.md (Decision 191407) : seulement si
# ce fichier precis est stage dans ce commit -- meme discipline que la
# fraicheur des index generes ci-dessus, aucun cout sur les commits qui ne le
# touchent pas.
if git diff --cached --name-only --diff-filter=ACMR -- "$MISSION_INDEX_PATH" 2>/dev/null | grep -qxF "$MISSION_INDEX_PATH"; then
  check_mission_index_line_cap
fi

exit "$FAIL"
