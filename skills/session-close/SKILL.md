---
name: session-close
description: "Close a work session: inventory holes, refuse to close while any remain, then produce the handoff and capture (Pilot) or the closing commit (Executor). Use when the Owner says wrap, close, or asks to end the session."
license: "MIT"
metadata:
  vault-implements: "workshop-production/decisions/DECISION-2026-09-01-144931-skills-v1-end-of-pass.md, vault/decisions/DECISION-2026-08-25-110935-journal-close-tag-and-keyed-doors.md, vault/rules/RULES-2026-08-23-224706-role-charter-and-session-determination.md"
  vault-validated: "2026-09-01"
---

Clôt une session de travail : inventorie les trous, refuse de clore tant qu'il en reste un, puis produit la passation. Ce skill ne se déclenche **jamais seul** : l'Owner le lance par le mot « wrap » (ou « close », « on ferme ») — principe `commande`, DECISION-144931 §2. Sur la surface Executor, la commande fixe est `/session-close`. Il ne pousse rien, ne supprime rien, ne tranche rien.

## 1. Détermine ta surface, mécaniquement

Tente un geste shell inoffensif (`git --version`). Il répond → branche **Executor** (§3). Pas de shell → branche **Pilot** (§2). La capacité mesurée décide.

## 2. Branche Pilot (chat)

1. **Inventaire des trous, mesuré.** Ouvre `closing-checklist.md` dans le dossier de ce skill et joue chaque ligne avec l'outil qu'elle nomme (MCP : `read_text_file`, `get_file_info`, `search_files`). Un trou est constaté, jamais supposé. Les six familles : Missions de `MISSION-INDEX.md` sans état final · RELAY reçus dans la conversation et non consommés · artefacts Pilot déposés dans la conversation et non commités · portes ouvertes sans ligne `CLOSE:` au journal · résidus signalés (rapports, RELAY) non arbitrés · état push des deux dépôts (`refs/remotes/origin/main` lu et comparé à la tête locale).
2. **Un trou → refus de clore.** Rends la liste des trous, chacun avec l'action qui le fermerait (Mission à écrire, arbitrage Owner, instruction ponctuelle). Tu ne clos pas ; tu attends le mot de l'Owner sur chaque trou. Un résidu « on verra plus tard » est un trou arbitré seulement si l'Owner l'a dit.
3. **Zéro trou → passation.** Dépose au canonique, dans cet ordre : le **handoff** (gabarit `vault/templates/handoff-template.md`, dossier `handoffs/` du projet) puis la **capture** (gabarit `vault/templates/capture-template.md`, dossier `captures/`). Patron de dépôt : `DRAFT-…` → `get_file_info` → horodatage mesuré → renommage définitif → `get_file_info` final, dans un seul tour. Le handoff porte, pour chaque fait, VERIFIED ou DECLARED, et une file de reprise ordonnée avec **un mot exact par point** (le mot que l'Owner collera). La capture liste les fautes Pilot de la session, une par ligne, datées.
4. **Rends la commande de clôture Executor** : un snippet, cinq rubriques (RULES-124937), portant les quatre interdits standards seulement et pointant le handoff par son chemin. Rien d'autre : la clôture Executor est fixée par le §3 de ce skill, pas par un texte libre.

## 3. Branche Executor (Claude Code, `/session-close`)

1. Conscience de position (répertoire courant, dépôt, chemins vers `vault/` et `workshop-build/`), puis lis le **handoff nommé** par la commande de clôture, intégralement.
2. **Journal** (`state/journal.md` du projet, via `vault/tools/append-journal.sh`) : une ligne `STATE:` de clôture — têtes des deux dépôts, avance sur `origin`, portes ouvertes restantes ; puis les lignes `CLOSE: <clé> -- <référence>` que le handoff prescrit, **une par porte, clé exacte** (DECISION-110935). Aucune `CLOSE:` que le handoff ne nomme pas. Toute ligne `STATE:`/`CLOSE:`/`REPRISE:` est un pointeur ≤ 300 caractères (DECISION-191407) — `append-journal.sh` la refuse fail-closed sinon (Mission 123) : rédiger le pointeur, laisser le récit au rapport ou au handoff.
3. `vault/tools/build-state.sh` sur le projet, puis `vault/tools/build-digest.sh` sur le même projet (Mission 121, digest d'ouverture plafonné) ; `MISSION-INDEX.md` à jour (toute Mission close de la session porte son état final) ; `vault/tools/build-indexes.sh` sur les racines touchées seulement.
4. **Un commit par dépôt touché**, fichier par fichier, diff inspecté, jamais `git add .` ; la sortie du hook collée. Refus de gardien = **STOP** avec verbatim, aucun contournement, aucun override.
5. RELAY de clôture en cinq lignes chiffrées (rubriques de RULES-124937), en fin de fenêtre.

## 4. Canari

Avant tout geste, les gabarits `handoff-template.md` et `capture-template.md` existent dans `vault/templates/` (`get_file_info` ou `test -f`). Un gabarit absent → `NOT-READY`, aucune clôture, la réparation est une Mission.

## Ce que ce skill ne fait pas

Ouvrir une session (`session-start`) · pousser (geste Owner, délégué par instruction nommée seulement) · trancher un trou (l'Owner) · fabriquer ou réécrire une Mission (`ecriture-de-mission`) · inventer une ligne `CLOSE:` absente du handoff · clore avec un trou « mineur ».

## Liens

- `see also` — [Liste des trous de clôture, une mesure par ligne](./closing-checklist.md)
- `applies` — [Décision — Fin de passe skills V1](../../../workshop-build/workshop-production/decisions/DECISION-2026-09-01-144931-skills-v1-end-of-pass.md) (hors Vault)
- `applies` — [Décision — Tag CLOSE: et portes à clé du journal](../../decisions/DECISION-2026-08-25-110935-journal-close-tag-and-keyed-doors.md)
- `applies` — [Décision — Journal et index en pointeurs](../../decisions/DECISION-2026-09-02-191407-journal-and-index-as-pointers-300-chars.md)
- `applies` — [Charte des rôles et détermination de session](../../rules/RULES-2026-08-23-224706-role-charter-and-session-determination.md)
- `see also` — [Relais entre rôles par mini-prompts à rubriques fixes](../../rules/RULES-2026-08-23-124937-role-relay-mini-prompts.md)
- `see also` — [Gabarit de handoff](../../templates/handoff-template.md)
- `see also` — [Gabarit de capture](../../templates/capture-template.md)
