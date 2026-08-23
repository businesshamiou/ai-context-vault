---
type: rules
title: "Relais entre rôles par mini-prompts à rubriques fixes"
description: "Format symétrique de passation entre la fenêtre Pilot et la fenêtre Executor : mini-prompt à l'aller, bloc RELAY au retour."
created_at: 2026-08-23T12:49:37-04:00
timezone: America/Montreal
status: active
scope: role-relay, mission-workflow
---

# RELAIS ENTRE RÔLES PAR MINI-PROMPTS

> ### Règle — relais entre rôles par mini-prompts
>
> **Aller.** Toute Mission part avec un mini-prompt de consommation, livré par le Pilot **en snippet copiable d'un seul geste** (bloc de code dans le chat), jamais en fichier à ouvrir ni en prose à recomposer. Cinq rubriques fixes, dans cet ordre :
>
> 1. Ligne de titre : `Session Executor — Mission <NNN> (<description courte>)` — elle nomme la session.
> 2. Racine d'ouverture : le Vault, chemin absolu, avec l'instruction d'y travailler.
> 3. Source à appliquer : le chemin du fichier Mission, relatif au Vault, à lire et appliquer intégralement.
> 4. Interdits absolus : toujours « aucun git push, aucun appel modèle, aucune suppression », plus les interdits propres à la Mission.
> 5. Sortie attendue : terminer la fenêtre par le bloc RELAY défini dans la Mission, rempli.
>
> Le mini-prompt ne duplique pas le contenu de la Mission.
>
> **Retour.** Tout rapport d'exécution se termine par un bloc `RELAY` affiché en fin de fenêtre Executor, aux rubriques fixes suivantes, dans cet ordre :
>
> ```text
> RELAY <NNN>
> Rapport   : <chemin du fichier REPORT déposé>
> Verdict   : <FAIT | PARTIEL | BLOQUÉ> + une ligne
> Critères  : <n>/<total> PASS
> Commits   : <dépôt> <hash> · <dépôt> <hash>
> À trancher: <une ligne, ou « rien »>
> ```
>
> **Pont.** L'Owner est le seul canal entre les deux fenêtres : il colle le mini-prompt à l'aller, il recolle le bloc `RELAY` au retour. Le Pilot reprend sur la foi du bloc, et ne relit le rapport entier que si le verdict ou la rubrique « À trancher » l'exige.
>
> **Portée.** La règle vaut pour toute action déléguée à l'Executor, Mission ou instruction ponctuelle, dans tous les projets.

## Liens

- `source` — [Proposal — Relais entre rôles par mini-prompts à rubriques fixes](../../workshop-build/workshop-production/proposals/PROPOSAL-2026-08-23-123648-role-relay-mini-prompts.md) (hors Vault)
- `voir aussi` — [Décision — Adoption de la règle du relais entre rôles](../decisions/DECISION-2026-08-23-124937-role-relay-mini-prompts.md)
