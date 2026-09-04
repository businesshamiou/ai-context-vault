---
title: "Liste de lecture d'ouverture de session, par rôle"
description: "Source unique du protocole d'ouverture lu par le skill session-start : les lectures de chaque rôle, dans l'ordre, avec la raison d'une ligne. C'est ce fichier qu'on amende quand le protocole change — le corps du skill ne bouge pas. Chaîne amended by suivie par le skill."
created_at: "2026-09-01T15:30:00-04:00"
timezone: America/Montreal
status: active
amends:
  - "../../rules/RULES-2026-08-23-224706-role-charter-and-session-determination.md"
---

# LISTE DE LECTURE D'OUVERTURE — PAR RÔLE

Lue par le skill `session-start` (étape 2). Une lecture par ligne, dans l'ordre. Ce qui a déjà été lu par le prompt d'ouverture de l'Owner n'est pas relu : vérifié, complété seulement.

## Pilot

Chaîne de pointeurs, dans cet ordre, chaque maillon nommant le suivant, aucun tenu de mémoire : instructions du Projet (hors dépôt, geste Owner) → charte `vault/rules/RULES-2026-08-23-224706-role-charter-and-session-determination.md` → ce fichier → digest → handoff → refs.

Lecture d'ouverture réduite au digest plafonné (Mission 121), budget aligné sur la chaîne d'entrée (Mission 136) : **huit appels filesystem** avant le verdict READY/NOT-READY quand le digest est frais, **dix au pire**, comptés un à un — (1) répertoires autorisés du serveur MCP, (2) `VAULT-ROOT.md` à la racine, (3) `CLAUDE.md` du Vault, (4) la charte, (5) ce fichier et le digest en un seul `read_multiple_files`, (6) le canari (un `get_file_info` sur le digest), (7) la mesure de fraîcheur (un `get_file_info` sur `state/journal.md`), (8) le handoff que le digest nomme et les quatre refs Git en un seul `read_multiple_files` — l'ordre digest → handoff → refs de la Décision 140714 point 2 est conservé ; un neuvième appel — le journal en `tail 5` — seulement si le digest est périmé, un dixième — `tail 30` — seulement si les cinq lignes ne suffisent pas (voir le test de fraîcheur) ; rien d'autre. Ce que le prompt d'ouverture a déjà fait lire compte dans les huit et n'est pas relu. Les recherches d'outils se comptent à part (Décision 145256). Le verdict est la **première ligne de prose** de la réponse d'ouverture, mot exact `READY` ou `NOT-READY (<motif mesuré>)` ; l'annonce `[role: …]` suit. Après l'état, la rubrique « Ouverture / budget » (Décision 140714, point 6) : appels d'outil comptés un à un ; octets rapportés — seul `get_file_info` rend une taille, donc le digest (canari) et le journal (mesure de fraîcheur) portent la leur, les autres lectures sont listées par nom avec la mention « taille non rapportée », jamais estimées ; recherches d'outils jouées et schémas chargés. Toute valeur d'état rapportée porte son statut : `VERIFIED` (lue sur disque dans cette session, source nommée), `DECLARED` (recopiée du digest ou du handoff, avec l'horodatage de la source), `ANOMALY` (désaccord entre deux sources, nommé tel quel).

1. `workshop-build/workshop-production/state/DIGEST.md`, entier — digest d'ouverture plafonné, généré par `vault/tools/build-digest.sh` (8 000 octets, fail-closed). **Test de fraîcheur** (Mission 119, transposé au digest par la Mission 121, rendu mesurable sans lecture par la Mission 136) : un `get_file_info` sur `state/journal.md` rend son horodatage de dernière modification ; s'il est **postérieur** à la ligne « Dernière entrée journal : \<horodatage\> » du digest, le digest est périmé ; égal ou antérieur, il est frais. Mesure de référence (2026-09-04) : modification 16:16:19 = dernière ligne datée 16:16:19, digest 16:11:47 — périmé d'une ligne, celle du push délégué, qui est le cas ordinaire après toute clôture poussée. Un checkout ou un clone récent peut rendre un « périmé » à tort (horodatage de fichier réinitialisé) ; jamais un « frais » à tort — le sens de l'erreur est sûr. S'il est périmé : le dire tel quel dans l'état en cinq lignes, lire le journal en `tail 5` à sa place (lignes plafonnées à 300 caractères depuis la Mission 123), `tail 30` seulement si la plus ancienne des cinq est encore postérieure à la ligne du digest, et ne pas le régénérer soi-même — la régénération (`vault/tools/build-digest.sh <projet>`, argument = dossier du projet) est un geste Executor prescrit par Mission. Le verdict READY/NOT-READY ne dépend pas de la fraîcheur.
2. Le dernier handoff de `workshop-build/workshop-production/handoffs/`, celui que le digest nomme en « Dernier handoff » (ou que le prompt d'ouverture nomme), entier — la file de reprise.
3. Refs Git des deux dépôts (`.git/refs/heads/main`, `.git/refs/remotes/origin/main`) par `read_multiple_files` — l'écart entre le disque et l'attendu. Chaque ref porte `VERIFIED` ; une ref recopiée du digest faute de lecture porte `DECLARED`. Refs et digest en désaccord = `ANOMALY` nommée — un commit de clôture postérieur au digest est le cas ordinaire, à dire tel quel. L'arbre de travail (`git status --porcelain`) n'est jamais mesurable depuis la surface Pilot : toujours `DECLARED`, valeur et horodatage du digest, jamais « propre » déduit de l'égalité des refs.

Parcimonie (Décision 140714) : l'artefact propre du Pilot — déposé dans la session, présent dans le contexte — n'est jamais relu en entier ; `edit_file` en `dryRun` est une mesure au sens de la Décision 212009 (l'échec sur chaîne absente est la mesure, le diff est la preuve), `head` ou `tail` sinon. Un mini-prompt est émis une fois : toute reprise dit « snippet inchangé » ou réémet la seule rubrique modifiée, nommée. Une recherche d'outils par famille, formulée sur la description de l'outil (verbe et objet : « search memories », « write file ») — l'index de recherche porte les descriptions, pas les noms (mesure 132-A) ; une seconde recherche est permise, et comptée au budget, si la première ne remonte pas l'outil visé. `recall` Mnemosyne en `limit 3`.

### Mnemosyne côté Pilot — rappel seul (Mission 126)

Le serveur MCP `mnemosyne`, quand il apparaît dans la liste d'outils, expose `recall`/`stats`/`diagnose` **et aussi** `store`/`remember`/`import`/`forget` : le serveur Mnemosyne (mesuré, `mcp_server.py`/`mcp_tools.py` de la version installée) ne porte **aucun mécanisme natif de restriction** de la liste d'outils exposée — ni option de démarrage, ni variable d'environnement, ni filtre côté serveur (`on_list_tools` retourne toujours l'ensemble complet). La règle qui suit est donc une **consigne d'auteur, non mécanisée**, tant qu'aucun gardien ou câblage ne la porte :

> **Mnemosyne côté Pilot : `recall` et `stats` seulement ; jamais `store`, `remember`, `forget`, `import`.** Toute écriture mémoire passe par le journal (`append-journal.sh`, Executor) — la mémoire d'un modèle n'est jamais une source d'état.

## Executor

1. Conscience de position : répertoire courant, dépôt, chemins relatifs vers `vault/` et `workshop-build/` (Décision 213150) — avant toute lecture.
2. La Mission nommée par le mini-prompt reçu, intégralement, section Contexte comprise — c'est la seule source d'instructions.
3. `git status -sb` des deux dépôts — l'écart entre le disque et l'attendu de la Mission.

## Liens

- `see also` — [Charte des rôles et détermination de session](../../rules/RULES-2026-08-23-224706-role-charter-and-session-determination.md)
- `amends` — [Charte des rôles et détermination de session](../../rules/RULES-2026-08-23-224706-role-charter-and-session-determination.md)
