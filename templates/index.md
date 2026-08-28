---
type: index
title: "Index — templates"
description: "Index généré automatiquement par tools/build-indexes.sh."
status: active
generated_by: tools/build-indexes.sh
---

# Index — templates

Index généré automatiquement. Ne pas éditer à la main : régénérer via `tools/build-indexes.sh`.

## Contenu

- `capture-template.md` — <titre concis> · capture · draft
- `current-state-template.md` — État courant — <nom du projet> · current-state · active
- `decision-template.md` — <titre de la décision> · decision · proposed
- `handoff-template.md` — <objet de la passation> · handoff · active
- `mission-template.md` — <titre de la Mission> · mission · AUTHORIZED           # autorisation à la création — figé, jamais retouché ensuite
  - <une à deux phrases>"  # écrites par l'auteur au moment du dépôt, jamais générées par un modèle tiers (232341 §2.1)
- `pilot-contract-template.md` — Gabarit — Contrat du Pilot · template · active
  - Sept lignes de contrat de comportement du Pilot, recopiées telles quelles en tête de toute fiche d'état générée par tools/build-state.sh. Plafonné à sept lignes, contrôle à l'appui.
- `project-registry-template.md` — Gabarit — Project Registry · template · active
  - Gabarit vide du Project Registry du Vault : en-têtes de colonnes et contrat d'écriture conservés, aucune ligne de données. Destiné à être instancié par le futur skill first-install (non construit par ce lot).
- `proposal-template.md` — <titre de la proposition> · proposal · proposed
- `report-template.md` — Rapport d'exécution — Mission <NNN> · report · FINAL
- `session-opening-prompt-template.md` — Gabarit — prompt d'ouverture minimal de session Pilot · template · active
  - Prompt de réouverture réduit à trois éléments : rôle, fiche d'état à lire, emplacement des blocs RELAY à recoller. Aucune règle de comportement ici — elle vit dans la fiche d'état (contrat du Pilot).
- `vault-root-template.md` — {{VAULT_NAME}} — marqueur de racine de travail · marker · active
  - Marqueur remonté : identifie la racine de travail et localise le Vault depuis n'importe quel dossier de projet.

## Liens

- `prescribed by` — [Standard de liens entre documents](../rules/RULES-2026-08-21-115658-document-linking-standard.md)
