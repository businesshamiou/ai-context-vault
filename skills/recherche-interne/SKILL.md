---
name: recherche-interne
description: "Search the Vault and the project corpus by discipline: indexes and description fields first, then exact grep or glob, and never assert a path that was not measured. Use when looking for a document, a rule, a decision, a term, or when asked where something lives."
license: "MIT"
metadata:
  vault-implements: "workshop-production/decisions/DECISION-2026-09-01-144931-skills-v1-end-of-pass.md, vault/decisions/DECISION-2026-08-29-212009-evidence-status-and-stop-control.md, workshop-production/knowledge-notes/KNOWLEDGE-NOTE-2026-08-30-211552-mnemosyne-retrieval-vs-vault-reel.md"
  vault-validated: "2026-09-01"
---

Cherche dans le Vault et le corpus d'un projet **par discipline, pas par moteur** (DECISION-144931 §6a, étude Mnemosyne : câbler l'existant plutôt qu'outiller du neuf). Deux surfaces : Pilot (MCP `read_text_file`, `search_files`, `get_file_info`) et Executor (shell : `cat`, `grep`, `find`, `vault/tools/find-in-vault.sh`). Ce skill **n'écrit rien** : il rend des chemins mesurés, ou « non trouvé ». Les quatre étapes se jouent dans l'ordre, aucune ne se saute.

## 1. Index d'abord — dévoilement progressif

Ouvre l'`index.md` de la racine concernée (`vault/index.md`, `vault/rules/index.md`, `vault/decisions/index.md`, `workshop-production/decisions/index.md`, `workshop-production/missions/index.md`, `vault/skills/index.md`, …) et lis le champ `description` de chaque entrée. Note les candidats : nom de fichier exact tel que listé, une ligne de raison. Ne descends dans un fichier qu'après l'index : c'est l'index qui dit ce qui existe.

## 2. Puis motif exact

Sur les candidats et sur le corpus : `search_files` (glob sur le nom) ou `grep` (motif exact sur le contenu, `grep -rn -- '<motif>' <racine>`), avec les exclusions `.git`, `node_modules`, et `skills/` sauf si les skills sont la cible (la bibliothèque externe est du matériel adopté, pas du corpus normatif). Un motif est **exact** : ce que tu as tapé, pas une approximation présentée comme telle. Zéro résultat se dit « 0 résultat pour `<motif>` dans `<racine>` », jamais « rien de pertinent ».

## 3. Remonte à la version en vigueur

Pour tout document trouvé, lis sa section `## Liens` : une ligne `amended by` ou `superseded by` désigne un document plus récent — suis-la jusqu'au dernier, et vérifie `superseded-files.txt` de la racine. La version en vigueur est celle que tu rends ; la version remplacée est nommée comme telle (faute « lecture d'un document remplacé », contrat du Pilot point 4 : un document marqué remplacé n'est pas une source).

## 4. Rends des chemins mesurés

La sortie est une liste : un chemin par ligne, relatif au workspace, chacun **mesuré** (`get_file_info` réussi, ou apparu dans un listage réel), une ligne de raison, et la mention « en vigueur » / « remplacé par … » (DECISION-212009 : un chemin est MESURÉ ou n'est pas). Un chemin reconstitué de mémoire ne se rend jamais. Ce qui n'a pas été trouvé se dit tel quel : « non trouvé : `<terme>` — index lus : …, motifs tentés : … ».

## Ce que ce skill ne fait pas

Recherche web (`research`, bibliothèque externe) · recherche d'images (aucun skill, règles en place) · écriture, dépôt, commit · résumé à la place du document (il rend l'adresse, pas le contenu) · affirmation d'un chemin non mesuré.

## Liens

- `applies` — [Décision — Fin de passe skills V1](../../../workshop-build/workshop-production/decisions/DECISION-2026-09-01-144931-skills-v1-end-of-pass.md) (hors Vault)
- `applies` — [Décision — Statut de preuve et contrôle du STOP](../../decisions/DECISION-2026-08-29-212009-evidence-status-and-stop-control.md)
- `applies` — [Note — Mnemosyne : retrieval contre Vault réel](../../../workshop-build/workshop-production/knowledge-notes/KNOWLEDGE-NOTE-2026-08-30-211552-mnemosyne-retrieval-vs-vault-reel.md) (hors Vault)
- `see also` — [Standard de liens entre documents](../../rules/RULES-2026-08-21-115658-document-linking-standard.md)
