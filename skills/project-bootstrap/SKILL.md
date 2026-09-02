---
name: project-bootstrap
description: "Make a project aware of the Vault at one of its three tiers: register it, pin the Vault guardians, install the pre-tool preflight hook, and propose (never impose) the seven-function layout. Use when adopting an existing project or starting a new one under the Vault."
license: "MIT"
metadata:
  vault-implements: "workshop-production/decisions/DECISION-2026-08-31-210731-project-vault-awareness-three-tiers.md, workshop-production/decisions/DECISION-2026-09-01-144931-skills-v1-end-of-pass.md, workshop-production/decisions/DECISION-2026-08-25-232341-evening-consolidation-project-standard-and-plan.md"
  vault-validated: "2026-09-01"
---

Rend un projet conscient du Vault à l'un de ses trois étages (DECISION-210731) : l'enregistre, épingle les gardiens, pose le hook `executor-preflight`, et **propose** la mise en sept fonctions sans jamais l'imposer. **Surface Executor seulement** (fichiers, Git local, hook). Ce skill ne se lance que sur prescription d'une Mission ou arbitrage Owner : adopter écrit dans le registre du Vault (DECISION-210731 point 2). La source de comportement est la Décision 210731, **à lire intégralement avant le premier geste** ; ce corps ne la paraphrase pas.

## 1. Mesure l'étage actuel et dis-le

Depuis la racine du projet : **machine** — un fichier global par outil existe (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`) et nomme le marqueur ; **workspace** — `VAULT-ROOT.md` trouvé en remontant, sa ligne « Chemin relatif du Vault » lue ; **projet** — présence de `AGENTS.md`/`CLAUDE.md` pointant la charte, de `.pre-commit-config.yaml` épinglé, de `.claude/settings.json` avec le hook `PreToolUse`, d'une ligne au registre `vault/projects/PROJECT-REGISTRY.md`, d'une fiche `vault/projects/PROJECT-<id>.md`. Rends l'étage mesuré. **Ne dégrade jamais un étage** : rien n'est retiré, rien n'est réécrit.

## 2. Mode adopter — projet existant

Ajoute ce qui manque, **sans toucher à aucun fichier existant du projet** (un fichier présent, même incomplet, est laissé tel quel et signalé) :
1. **Ligne au registre** (`vault/projects/PROJECT-REGISTRY.md`, colonnes du gabarit `project-registry-template.md` : `project_id | display_name | status | relative_path | conformity`) et **fiche v2** `vault/projects/PROJECT-<project_id>.md`, au schéma qu'écrit `vault/tools/project-bootstrap.sh` (le lire au moment d'écrire, ne pas le recopier de mémoire) ; `conformity` mesurée par `vault/tools/check-project-conformity.sh <projet>`.
2. **Épingle** `.pre-commit-config.yaml` : le dépôt du Vault, `rev:` = **tête poussée** du Vault (`git -C vault rev-parse origin/main`), jamais un commit local non poussé — l'écart signalé par le canari de session-start le 1er septembre venait de là ; hooks : `vault-check-secrets`, `vault-check-indexes-fresh`, `vault-check-links` (les ids exposés par le Vault).
3. **Hook `executor-preflight`** : copie `preflight-hook.sh` (compagnon de ce skill) en `.claude/hooks/preflight-hook.sh` du projet ; fusionne le fragment `settings-hook.json` (compagnon) dans `.claude/settings.json` — s'il existe déjà, ne le modifie pas : rends le fragment à fusionner à la main et signale-le.
4. **Fichiers de pointage** `AGENTS.md` et `CLAUDE.md` (étage projet, DECISION-210731 point 1) : une ligne qui renvoie à la charte des rôles par chemin relatif mesuré, comme le `CLAUDE.md` du Vault. Absents seulement.
5. `pre-commit install` dans le projet si `pre-commit` est disponible ; sinon signalé comme geste humain restant.

## 3. Mode nouveau — projet à naître

`vault/tools/project-bootstrap.sh <chemin-cible> <display_name>` (squelette des sept fonctions créé vide, README, journal, index, fiche v2, ligne de registre — comportement existant, DECISION-210731 point 3 « naître »), puis les étapes 2 à 5 du §2 : épingle, hook, pointage, `pre-commit install`.

## 4. Propose la réorganisation, n'applique jamais seul

En fin de course, sur un projet adopté : présente le **plan de réorganisation** en sept fonctions (`README.md`, `rules/`, `state/`, `missions/`, `decisions/`, `proposals/`, `knowledge/`, `handoffs/` — RULES-142800 §2) : la liste des déplacements, ce qui bougerait et où, **aucun exécuté**. Elle ne s'applique que sur un « oui » catégorique de l'Owner **écrit dans la Mission** qui lance ce skill — jamais sur un oui de conversation. Sans ce oui : le projet reste tel quel, adopté mais non réorganisé, et la fiche v2 le dit.

## 5. Verdict

Étage avant → étage après ; liste des fichiers ajoutés ; **rien de modifié** — preuve : `git status --porcelain` du projet ne montre que des `??` (ou des `A`), aucun ` M` ; sortie de `check-project-conformity.sh` collée ; le plan de réorganisation proposé ; les gestes humains restants.

## Ce que ce skill ne fait pas

Ouvrir ou clore une session (`session-start`, `session-close`) · pousser · modifier ou déplacer un fichier existant du projet · appliquer les sept fonctions sans le oui écrit dans la Mission · adopter `workshop-build`, le Vault ou un entrepôt sans Mission dédiée · installer le poste (`first-install`) · dégrader un étage.

## Liens

- `see also` — [Hook executor-preflight, à copier dans le projet](./preflight-hook.sh)
- `see also` — [Fragment PreToolUse à fusionner dans .claude/settings.json](./settings-hook.json)
- `applies` — [Décision — Prise de conscience du Vault par un projet, trois étages](../../../workshop-build/workshop-production/decisions/DECISION-2026-08-31-210731-project-vault-awareness-three-tiers.md) (hors Vault)
- `applies` — [Décision — Fin de passe skills V1](../../../workshop-build/workshop-production/decisions/DECISION-2026-09-01-144931-skills-v1-end-of-pass.md) (hors Vault)
- `applies` — [Décision — Consolidation du soir, standard de projet et plan](../../../workshop-build/workshop-production/decisions/DECISION-2026-08-25-232341-evening-consolidation-project-standard-and-plan.md) (hors Vault)
- `see also` — [Standard de structure de projet, sept fonctions](../../rules/RULES-2026-08-26-142800-project-structure-standard.md)
- `see also` — [Gabarit du registre des projets](../../templates/project-registry-template.md)
- `see also` — [Registre des projets](../../projects/PROJECT-REGISTRY.md)
