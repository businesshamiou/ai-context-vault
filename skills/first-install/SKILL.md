---
name: first-install
description: "Install the Vault on a machine for the first time or complete a partial install: interrogate the host, install what is missing without overwriting what exists, and report what remains a human gesture. Use when setting up a new machine, or when asked to verify or repair an installation."
license: "MIT"
metadata:
  vault-implements: "workshop-production/decisions/DECISION-2026-09-01-144931-skills-v1-end-of-pass.md, workshop-production/decisions/DECISION-2026-08-28-171209-skills-adoption-by-v1-envelope-rewrite.md, workshop-production/decisions/DECISION-2026-08-31-210731-project-vault-awareness-three-tiers.md"
  vault-validated: "2026-09-01"
---

Installe le Vault sur un poste pour la première fois, ou complète une installation partielle : interroge le poste, installe **ce qui manque seulement**, sans écraser ce qui existe, et rend ce qui reste un geste humain. **Surface Executor seulement** (DECISION-144931 §5). Rejouable : sur un poste déjà installé, il complète et son verdict dit « 0 manquant ». Fabriqué en dernier de la passe V1 : installer tout exige d'avoir vu tout.

## 1. Interrogatoire — par `/to-questionnaire`

Les questions dont la réponse est **mesurable** sont mesurées, jamais posées : OS et shell (`uname -s`, `$SHELL`), version de Claude Code (`claude --version`), Git et `core.hooksPath` du Vault (`git -C vault config core.hooksPath`), support des jonctions (`fsutil` / `mklink /J` sur Windows, `ln -s` ailleurs), outils requis par les gardiens (`bash`, `sha256sum`, `pre-commit`), racine MCP filesystem configurée. Les questions dont la réponse est **humaine** — chemin voulu du Vault, chemin des projets, dossier personnel des skills — sont posées **une fois** par le skill `to-questionnaire` de la bibliothèque (invocation manuelle `/to-questionnaire`, DECISION-144931 §5 et §7 ; ce skill ne le réécrit pas) et leurs réponses consignées dans le rapport d'installation.

## 2. Inventaire avant tout geste

Joue `install-checklist.md` (compagnon de ce skill) ligne par ligne : chaque item est mesuré `installé` ou `manquant` avec sa preuve. Ce qui est installé **reste tel quel** : aucun fichier existant n'est réécrit, aucune jonction existante n'est recréée, aucun `core.hooksPath` déjà posé n'est retouché.

## 3. Installation de ce qui manque seulement

Dans l'ordre : les **jonctions** `%USERPROFILE%\.claude\skills\<nom>` → `vault/skills/<nom>` (skills fabriqués par le Vault) et → `vault/skills/external/<nom>` (bibliothèque adoptée, DECISION-171209), liste = dossiers **mesurés** sur disque, chacune prouvée par `test <jonction>/SKILL.md -ef <cible>/SKILL.md` ; `core.hooksPath = .githooks` dans le Vault ; `pre-commit install` dans chaque projet enregistré (`vault/projects/PROJECT-REGISTRY.md`, colonne `relative_path` — fichier `INTERNE`, absent sur un clone neuf : 0 projet, rien à faire, il est créé par `project-bootstrap` au premier projet, jamais par ce skill) si `pre-commit` est disponible ; l'**étage machine** (DECISION-210731 point 1) — un fichier global par outil (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`) au contenu minimal (il existe un Vault ; remonter jusqu'au marqueur `VAULT-ROOT.md` ; lire la charte à son emplacement ; déterminer le rôle ; ne rien faire avant), **absent seulement** — un fichier global existant est laissé tel quel et son contenu signalé ; enfin le **rapport d'installation** (gabarit `install-report-template.md`, compagnon) déposé au chemin que l'Owner a nommé à l'interrogatoire, ou rendu en conversation si aucun.

## 4. Skills chat — proposés, jamais déclarés installés

Liste les archives zip des skills à importer par l'humain dans claude.ai, chemin mesuré de chacune (paquet du warehouse ou export du Vault). L'import chat est un **geste Owner constaté** (DECISION-144931 §5) : le rapport les marque `laissé (geste humain)`, jamais `installé`.

## 5. Verdict

Table `installé / manquant → installé / laissé (geste humain)`, une ligne par item de la checklist, preuve collée (chemin, `test -ef`, sortie de commande) ; total « N manquant » avant, « 0 manquant » après ou la liste de ce qui reste ; `git status -sb` du Vault identique avant/après (ce skill n'écrit rien dans un dépôt Git). Relance possible : rejouer donne « 0 manquant » et zéro écriture.

## Ce que ce skill ne fait pas

Bootstrap d'un projet (`project-bootstrap`) · ouvrir ou clore une session · pousser · importer dans claude.ai (geste humain) · écraser un fichier ou une jonction existants · écrire dans un dépôt Git · réécrire `to-questionnaire`.

## Liens

- `see also` — [Liste d'installation, une mesure par item](./install-checklist.md)
- `see also` — [Gabarit du rapport d'installation](./install-report-template.md)
- `see also` — [Skill to-questionnaire, bibliothèque externe](../external/to-questionnaire/SKILL.md)
- `applies` — [Décision — Fin de passe skills V1](../../../workshop-build/workshop-production/decisions/DECISION-2026-09-01-144931-skills-v1-end-of-pass.md) (hors Vault)
- `applies` — [Décision — Adoption des skills par réécriture d'enveloppe V1, jonctions](../../../workshop-build/workshop-production/decisions/DECISION-2026-08-28-171209-skills-adoption-by-v1-envelope-rewrite.md) (hors Vault)
- `applies` — [Décision — Prise de conscience du Vault par un projet, trois étages](../../../workshop-build/workshop-production/decisions/DECISION-2026-08-31-210731-project-vault-awareness-three-tiers.md) (hors Vault)
- `see also` — [Registre des projets](../../projects/PROJECT-REGISTRY.md)
