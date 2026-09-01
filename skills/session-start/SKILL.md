---
name: session-start
description: "Open a work session: measure repo and guardian state, read the state files in order, and announce role and readiness. Use at the start of any session, or when asked to (re)open, resume, or check readiness."
license: "MIT"
metadata:
  vault-implements: "workshop-production/decisions/DECISION-2026-09-01-144931-skills-v1-end-of-pass.md, workshop-production/decisions/DECISION-2026-08-31-210731-project-vault-awareness-three-tiers.md, vault/rules/RULES-2026-08-23-224706-role-charter-and-session-determination.md"
  vault-validated: "2026-09-01"
---

Ouvre une session de travail : mesure l'état du poste, lis les fichiers d'état dans l'ordre, annonce le rôle et le verdict de préparation. Ce skill est **en lecture seule** : il ne dépose rien, ne commite rien, ne déplace rien — jamais, sur aucune surface. Il complète le prompt d'ouverture de l'Owner, il ne le remplace pas : ce que le prompt a déjà fait lire, ne le relis pas — vérifie que c'est fait et comble les manques seulement.

## 1. Détermine ta surface, mécaniquement

Tente un geste shell inoffensif (`git --version`). Il répond → branche **Executor**. Pas de shell (chat, MCP seul) → branche **Pilot**. La capacité mesurée décide ; ne te déclare jamais un rôle que tu n'as pas mesuré.

## 2. Lis la liste de lecture de ton rôle

Ouvre `reading-list.md` dans le dossier de ce skill et exécute les lectures de ta section, dans son ordre. Si ce fichier porte une ligne `amended by`, lis aussi l'amendement et applique-le : c'est lui la source du protocole d'ouverture, pas ce corps.

## 3. Mesure le canari de ta branche

**Pilot** : la racine MCP répond (un `get_file_info` sur la fiche d'état) ; la fiche d'état est lisible et datée ; le handoff qu'elle pointe existe.

**Executor** : conscience de position d'abord (répertoire courant, dépôt, chemins relatifs vers `vault/` et `workshop-build/`). Puis les trois mesures : (a) `rev:` de `workshop-build/.pre-commit-config.yaml` comparé à la tête du Vault (`vault/.git/refs/heads/main`) — un écart signifie des gardiens épinglés en retard ; (b) le hook natif présent (`vault/.githooks/pre-commit`) et `core.hooksPath` qui pointe dessus ; (c) chaque script gardien nommé par le hook présent dans `vault/tools/`. Enfin `git status -sb` des deux dépôts, collé tel quel.

## 4. Rends le verdict, puis arrête-toi

Format, dans cet ordre : la ligne `READY` ou `NOT-READY (<motif mesuré, verbatim>)` ; l'annonce `[role: <pilot|executor> · <plan|implement|validate> · open]` ; un état en cinq lignes chiffrées maximum (têtes des dépôts, avance sur origin, portes ouvertes, dernier handoff, écarts de `git status`).

`NOT-READY` a une seule conséquence, non négociable : **Executor — aucun geste** (ni écriture ni commit de toute la fenêtre) ; **Pilot — aucun dépôt** de toute la session. Lire et discuter restent permis. La réparation est une Mission ou un arbitrage Owner, jamais un geste de ce skill.

## Ce que ce skill ne fait pas

La clôture (`session-close`) · l'installation ou la réparation du poste (`first-install`, `project-bootstrap`) · la pose du hook (bootstrap) · la moindre écriture, y compris une ligne de journal — l'annonce vit dans la conversation · la recherche : tu lis une liste fixée, tu ne fouilles pas.

## Liens

- `see also` — [Liste de lecture d'ouverture de session, par rôle](./reading-list.md)
- `see also` — [Charte des rôles et détermination de session](../../rules/RULES-2026-08-23-224706-role-charter-and-session-determination.md)
