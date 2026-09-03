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

Lecture d'ouverture réduite au digest plafonné (Mission 121) : trois lectures, rien d'autre avant le verdict READY/NOT-READY.

1. Le dernier handoff de `workshop-build/workshop-production/handoffs/` (celui que le digest ou le prompt d'ouverture nomme), entier — la file de reprise.
2. `workshop-build/workshop-production/state/DIGEST.md`, entier — digest d'ouverture plafonné, généré par `vault/tools/build-digest.sh` (8 000 octets, fail-closed). **Test de fraîcheur** (Mission 119, transposé au digest par la Mission 121) : sa ligne « Dernière entrée journal : \<horodatage\> » doit être égale à la dernière ligne datée de `state/journal.md`. S'il est plus ancien, le digest est périmé : le dire tel quel dans l'état en cinq lignes, lire le journal (tail 30) à sa place, et ne pas le régénérer soi-même — la régénération (`vault/tools/build-digest.sh <projet>`, argument = dossier du projet) est un geste Executor prescrit par Mission. Le verdict READY/NOT-READY ne dépend pas de la fraîcheur.
3. Refs Git des deux dépôts (`.git/refs/heads/main`, `.git/refs/remotes/origin/main`) par `read_multiple_files` — l'écart entre le disque et l'attendu.

### Mnemosyne côté Pilot — rappel seul (Mission 126)

Le serveur MCP `mnemosyne`, quand il apparaît dans la liste d'outils, expose `recall`/`stats`/`diagnose` **et aussi** `store`/`remember`/`import`/`forget` : le serveur Mnemosyne (mesuré, `mcp_server.py`/`mcp_tools.py` de la version installée) ne porte **aucun mécanisme natif de restriction** de la liste d'outils exposée — ni option de démarrage, ni variable d'environnement, ni filtre côté serveur (`on_list_tools` retourne toujours l'ensemble complet). La règle qui suit est donc une **consigne d'auteur, non mécanisée**, tant qu'aucun gardien ou câblage ne la porte :

> **Mnemosyne côté Pilot : `recall` et `stats` seulement ; jamais `store`, `remember`, `forget`, `import`.** Toute écriture mémoire passe par le journal (`append-journal.sh`, Executor) — la mémoire d'un modèle n'est jamais une source d'état.

## Executor

1. Conscience de position : répertoire courant, dépôt, chemins relatifs vers `vault/` et `workshop-build/` (Décision 213150) — avant toute lecture.
2. La Mission nommée par le mini-prompt reçu, intégralement, section Contexte comprise — c'est la seule source d'instructions.
3. `git status -sb` des deux dépôts — l'écart entre le disque et l'attendu de la Mission.

## Liens

- `see also` — [Charte des rôles et détermination de session](../../rules/RULES-2026-08-23-224706-role-charter-and-session-determination.md)
