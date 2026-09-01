---
title: "Liste de lecture d'ouverture de session, par rôle"
description: "Source unique du protocole d'ouverture lu par le skill session-start : les lectures de chaque rôle, dans l'ordre, avec la raison d'une ligne. C'est ce fichier qu'on amende quand le protocole change — le corps du skill ne bouge pas. Chaîne amended by suivie par le skill."
created_at: "2026-09-01T15:30:00-04:00"
timezone: America/Montreal
status: active
---

# LISTE DE LECTURE D'OUVERTURE — PAR RÔLE

Lue par le skill `session-start` (étape 2). Une lecture par ligne, dans l'ordre. Ce qui a déjà été lu par le prompt d'ouverture de l'Owner n'est pas relu : vérifié, complété seulement.

## Pilot

1. `workshop-build/workshop-production/state/STATE.md` — la fiche d'état, contrat en tête ; c'est elle qui pointe le reste.
2. `workshop-build/workshop-production/state/journal.md` — queue (tail 15) ; l'état net des portes et les derniers gestes.
3. Le dernier handoff de `workshop-build/workshop-production/handoffs/` (celui que la fiche d'état ou le prompt d'ouverture nomme) — la file de reprise.
4. La capture liée à ce handoff dans `workshop-build/workshop-production/captures/`, si le handoff en nomme une — les leçons de la session close.

## Executor

1. Conscience de position : répertoire courant, dépôt, chemins relatifs vers `vault/` et `workshop-build/` (Décision 213150) — avant toute lecture.
2. La Mission nommée par le mini-prompt reçu, intégralement, section Contexte comprise — c'est la seule source d'instructions.
3. `git status -sb` des deux dépôts — l'écart entre le disque et l'attendu de la Mission.

## Liens

- `see also` — [Charte des rôles et détermination de session](../../rules/RULES-2026-08-23-224706-role-charter-and-session-determination.md)
