---
title: "Liste de contrôle de forme d'une Mission, une faute par ligne"
description: "Registre des fautes Pilot rendu exécutable : chaque ligne est un contrôle de forme joué par le skill ecriture-de-mission avant le dépôt d'une Mission, avec la faute datée ou la Décision qui l'a payée. C'est ce fichier qu'on amende quand une faute nouvelle est attrapée — le corps du skill ne bouge pas. Chaîne amended by suivie par le skill."
created_at: "2026-09-01T19:30:00-04:00"
timezone: America/Montreal
status: active
---

# LISTE DE CONTRÔLE DE FORME D'UNE MISSION

Jouée par le skill `ecriture-de-mission` (§5) avant tout dépôt. Une ligne en échec = pas de dépôt. Chaque ligne cite ce qui l'a payée.

| # | Contrôle | Mesure | Payé par |
|---|---|---|---|
| 1 | Section `## Contexte` présente, entre le rappel de statut et `## Objectif`, avec ses quatre contenus dans l'ordre (faits mesurés datés et qualifiés ; ce que l'Executor trouvera sur disque ; pièges connus ; pourquoi la décision autorisante est ce qu'elle est) | relecture de la section contre le gabarit | DECISION-2026-09-01-115547 point 1 ; Missions 090 et 108 (contexte reconstitué à l'exécution) |
| 2 | Relecture croisée tracée : commentaire HTML en tête de `## Validations`, chaque compte atteignable sans violer Gates ni Contraintes, chaque étape permise | lecture Validations ↔ Gates ↔ Contraintes ↔ Étapes, deux à deux | DECISION-115547 point 2 ; faute 090 ; faute 108 ×2 (Validations vs Interdits absolus, étape 8 vs mini-prompt) |
| 3 | Mini-prompt : quatre interdits standards seulement + renvoi aux Gates et Contraintes, aucun interdit propre | relecture de la rubrique 4 du snippet | DECISION-115547 point 3 ; Mission 108 (interdit du mini-prompt contredisant l'étape 8) |
| 4 | Chaque fait du Contexte porte `MESURÉ` / `DECLARED` / `HYPOTHÈSE` et une date | grep des trois marqueurs, un par fait | DECISION-2026-08-29-212009 (statut de preuve) |
| 5 | Chaque lien `## Liens` et chaque nom de fichier cité obtenus par `search_files` ou listage, jamais de mémoire | `get_file_info` sur chaque cible avant dépôt | faute du 30 août (lien écrit de mémoire avec un mauvais nom) |
| 6 | Chaque existence affirmée (« le hook existe », « le script est câblé ») mesurée | `get_file_info` / lecture du fichier | faute « le hook existe » (30 août, non mesuré) |
| 7 | Section `## Liens` présente, `prescribed by` le standard de versionnement + `applies` sur chaque Décision appliquée ; cibles hors dépôt suffixées `(hors <dépôt>)` | `check-links.sh` règle 1 ; relecture | Mission 112 premier STOP (`## Liens` absente d'un fichier déposé par le Pilot) |
| 8 | Tout `amends` / `supersedes` en `## Liens` vers un document du même dépôt a son miroir front-matter (`amends:` / `superseded_by:`), en **forme chaîne ou liste bloc, jamais liste flux `[…]`** | lecture du front-matter du document lié | Mission 112 second STOP (miroir absent) et troisième STOP (liste flux illisible par le gardien) |
| 9 | Aucun renommage d'un document déjà lié ailleurs ; s'il faut renommer, la Mission le dit et répare les liens entrants | `search_files` sur l'ancien nom | faute 105-C01 (Décision renommée après dépôt → lien mort) |
| 10 | `created_at` = horodatage mesuré = horodatage du nom de fichier ; `mission_id` = numéro du nom | comparaison des trois | RULES-2026-08-17-211522 (versionnement) ; patron DRAFT (DECISION-2026-08-27-100016) |
| 11 | Préconditions avec statut de preuve et clause STOP explicite ; tolérances de `git status` nommées fichier par fichier | relecture de `## Préconditions` | Mission 113 STOP à la précondition 1 (2026-09-01) ; Mission 112 (fichier Mission non nommé à la tolérance) |
| 12 | Aucune étape « supprimer » : déplacement vers `_trash/` avec empreinte, ou human gate Owner hors des étapes | grep « supprim » dans `## Étapes` | DECISION-2026-08-29-110852 (suppression = geste Owner) |
| 13 | Gates : mot Owner verbatim et daté ; human gate non accordé listé ; conditions d'arrêt listées | relecture de `## Gates` | DECISION-2026-08-29-212009 ; charte §3 (refus = STOP) |
| 14 | Une seule fenêtre Executor prévue par dépôt ; la Mission nomme les fichiers concurrents qu'elle tolère | relecture du Contexte et des tolérances | trois frottements du 2026-09-01 (rangement 110 différé, 109 jouée deux fois, commit 111 refusé) |
| 15 | La ligne d'index de la Mission (`MISSION-INDEX.md`) est un pointeur ≤ 300 caractères : horodatage/tag/résumé d'une phrase/nom de fichier, jamais le récit | `wc -m` sur la ligne rédigée | DECISION-2026-09-02-191407 (journal et index en pointeurs) ; gardien `check-indexes-fresh.sh` (Mission 123) |

## Liens

- `see also` — [Skill ecriture-de-mission](./SKILL.md)
- `applies` — [Décision — Cohérence interne des Missions](../../../workshop-build/workshop-production/decisions/DECISION-2026-09-01-115547-mission-context-coherence-and-least-powerful-reading.md) (hors Vault)
- `applies` — [Décision — Journal et index en pointeurs](../../decisions/DECISION-2026-09-02-191407-journal-and-index-as-pointers-300-chars.md)
- `see also` — [Gabarit de Mission](../../templates/mission-template.md)
