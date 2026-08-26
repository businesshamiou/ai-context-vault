---
type: project-record
title: "Workshop IA / Mini Second Brain"
description: "Fiche de projet : fabrication et dogfooding du workshop IA."
project_id: 2026-08-17-AI-CTX-WRKS
display_name: "Workshop IA / Mini Second Brain"
status: ACTIVE
relative_path: workshop-build
purpose: "Fabrication et dogfooding du workshop IA / mini second brain."
canonical_context: "workshop-production/captures/CAPTURE-2026-08-19-013315-workshop-master-context-consolidated.md"
entry_point: "workshop-production/missions/MISSION-INDEX.md"
last_verified: 2026-08-19
stale_after: 90d
structure_standard: "../rules/RULES-2026-08-26-142800-project-structure-standard.md"
conformity: ÉCART
last_conformity_check: 2026-08-26
---

# PROJECT — WORKSHOP IA / MINI SECOND BRAIN

## Identity

- `project_id` : `2026-08-17-AI-CTX-WRKS`
- `display_name` : Workshop IA / Mini Second Brain
- `status` : `ACTIVE`

## Location

- `relative_path` : `workshop-build`, relatif au parent du Vault.

## Entry Points

Chemins relatifs à la racine du projet.

- Contexte canonique : [`workshop-production/captures/CAPTURE-2026-08-19-013315-workshop-master-context-consolidated.md`](../../workshop-build/workshop-production/captures/CAPTURE-2026-08-19-013315-workshop-master-context-consolidated.md) (hors Vault)
- État courant : [`workshop-production/missions/MISSION-INDEX.md`](../../workshop-build/workshop-production/missions/MISSION-INDEX.md) (hors Vault)

## Notes

Premier projet inscrit au Registry. Ce projet fabrique le workshop qui enseigne la méthode ; il est simultanément produit pédagogique, premier test réel du système et case study principal.

## Conformité (registre v2)

- `structure_standard` : [Standard de structure de projet](../rules/RULES-2026-08-26-142800-project-structure-standard.md)
- `conformity` : `ÉCART`, mesuré le `2026-08-26` par `tools/check-project-conformity.sh workshop-build` — manques : `state, missions, decisions, proposals, knowledge, handoffs`.
- Écart couvert par la clause du grand-père (standard §5) : les sept fonctions existent réellement, mais nichées sous `workshop-production/` plutôt qu'à la racine du dépôt `workshop-build` — antérieur au standard, non restructuré (coût connu, gain nul). Constat, pas un défaut à corriger.

## Liens

- `source` — [workshop-production/captures/CAPTURE-2026-08-19-013315-workshop-master-context-consolidated.md](../../workshop-build/workshop-production/captures/CAPTURE-2026-08-19-013315-workshop-master-context-consolidated.md) (hors Vault)
- `source` — [workshop-production/missions/MISSION-INDEX.md](../../workshop-build/workshop-production/missions/MISSION-INDEX.md) (hors Vault)
- `source` — [Standard de structure de projet](../rules/RULES-2026-08-26-142800-project-structure-standard.md)
