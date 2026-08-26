---
type: project-registry
title: "Project Registry — index des projets connus du Vault"
description: "Carte minimale des projets : identité, emplacement et point d'entrée."
created_at: 2026-08-19T11:53:06-04:00
timezone: America/Montreal
status: active
write_contract: "executor-only — voir DECISION project-registry-v1"
---

# PROJECT REGISTRY

Index des projets connus du Vault. Le Vault connaît l'adresse des projets, pas leur contenu : chaque projet reste la source canonique de sa propre mémoire. Le détail de chaque projet vit dans sa fiche `PROJECT-<project_id>.md`.

Les chemins sont relatifs au parent du Vault.

## Active

| project_id | display_name | status | relative_path | conformity |
|---|---|---|---|---|
| 2026-08-17-AI-CTX-WRKS | Workshop IA / Mini Second Brain | ACTIVE | workshop-build | ÉCART (grand-père, voir fiche) |

## Paused

Aucun projet.

## Archived

Aucun projet.

## Liens

- `source` — [Decision — Project Registry V1](../decisions/DECISION-2026-08-19-115306-project-registry-v1.md)
- `source` — [Standard de structure de projet](../rules/RULES-2026-08-26-142800-project-structure-standard.md)
