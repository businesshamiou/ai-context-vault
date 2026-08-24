---
type: knowledge
title: "Runbook d'installation du Vault — V1"
created_at: 2026-08-21T10:51:17-04:00
timezone: America/Montreal
status: active
---

# RUNBOOK D'INSTALLATION DU VAULT — V1

Mode d'emploi ordonné pour installer et vérifier le Vault et son outillage. Complète le [README](../README.md) (pourquoi/quoi) par le comment. Chaque ligne de fait porte `[VERIFIED]` (mesurée par l'Executor au moment de l'écriture, commande à l'appui) ou `[DECLARED — source]` (reprise d'un document cité). Une ligne `DECLARED` devient `VERIFIED` quand une Mission ultérieure la mesure. Voir les [deux principes de vérification](./verification-and-evidence.md) : *measure, don't copy*.

**Obligation de mise à jour** : toute Mission qui installe, met à jour, configure ou retire un composant met ce runbook à jour **dans le même commit** ([Decision](../decisions/DECISION-2026-08-21-105117-vault-installation-runbook.md)). Le rapport d'exécution de cette Mission porte une section « Impact sur l'installation ».

## 1. Prérequis

- [VERIFIED] OS : Windows, `cmd /c ver` → `Microsoft Windows [version 10.0.26200.9168]` (Windows 11 Pro).
- [VERIFIED] Git : `git --version` → `git version 2.55.0.windows.2`.
- [VERIFIED] Python : la commande nue `python` sur ce poste ne résout **pas** vers un interpréteur (`python --version` renvoie le message de l'alias Microsoft Store « Python was not found »). Un interpréteur réel existe : `python3.12.exe` → `Python 3.12.13`, à `C:\Users\hamio\.local\bin\python3.12.exe`.
- [VERIFIED] `uv` : `uv --version` → `uv 0.11.28 (ebf0f43d7 2026-07-07 x86_64-pc-windows-msvc)`, à `C:\Users\hamio\.local\bin\uv.exe`. C'est le gestionnaire utilisé pour installer Graphify (§4).
- [VERIFIED] Node.js : `node --version` → `v24.18.0`. Non requis par le Vault lui-même ; présent sur le poste.
- [VERIFIED] Claude Code (CLI) : `claude --version` → `2.1.238 (Claude Code)`. C'est la session Executor.
- [DECLARED — `CAPTURE-2026-08-19-013315`] Claude Desktop est utilisé par le Pilot, installé via Microsoft Store (virtualisation MSIX — voir §5).

## 2. Dépôts

- `vault` (ce dépôt) : transversal — `decisions/`, `knowledge/`, `rules/`, `templates/`, `skills/`, `handoffs/`, `tests/`, `graphify-out/`, `AGENTS.md`, `README.md`. [VERIFIED] `git remote -v` → `origin https://github.com/businesshamiou/ai-context-vault.git` (fetch + push). Branche : `main`.
- `workshop-build` (dépôt frère, `../workshop-build` depuis `vault`) : missions, prompts, rapports, audits, captures, proposals, handoffs, registre (`MISSION-INDEX.md`). [VERIFIED] `git remote -v` → `origin https://github.com/businesshamiou/workshop-build.git` (fetch + push). Branche : `main`.
- [DECLARED — `CAPTURE-2026-08-19-013315`] Relation frère : les deux dépôts sont clonés côte à côte, `workshop-build` accessible depuis `vault` via `../workshop-build` et réciproquement.
- Les sessions Executor s'ouvrent **uniquement dans `vault`** (§6).

## 3. Git

- [VERIFIED] `git config core.hooksPath` → `.githooks`. Cette configuration est **locale, non versionnée** : à refaire après tout clone (`git config core.hooksPath .githooks`) — [DECLARED — `AGENTS.md:12`].
- [VERIFIED] Contenu de `.githooks/` : `commit-msg`, `post-checkout`, `post-commit`, `pre-commit`, `pre-push` (tous exécutables).
  - `pre-commit`, `pre-push`, `commit-msg` : garde-fous (contrôle de secrets — voir `tools/check-secrets.sh`, qui refuse par défaut si `rules/patterns/secret-patterns.txt` est introuvable ; contrôle de liens — voir `tools/check-links.sh`, appelé juste après dans `pre-commit`, qui bloque tout `.md` stagé sans section `## Liens` ou avec un lien relatif cassé, et avertit sans bloquer en l'absence de lien interne — [Standard de liens entre documents](../rules/RULES-2026-08-21-115658-document-linking-standard.md)).
  - `post-commit`, `post-checkout` : écrits par Graphify, déclenchent une reconstruction **syntaxique** du graphe après un commit ou un changement de branche — analyse locale, sans appel à un modèle, sans transmission de contenu [DECLARED — `DECISION-2026-08-19-233650-graphify-integrations-amendment.md`, D1].
  - Ne jamais modifier un hook écrit par l'outil [DECLARED — `AGENTS.md:17`] ; un rôle ne modifie pas son propre garde-fou.
- [VERIFIED] `.gitattributes` → `graphify-out/graph.json merge=graphify` (merge driver dédié pour éviter les conflits sur le graphe généré).
- [VERIFIED] `graphify hook status` → `post-commit: installed`, `post-checkout: installed`, `merge driver: registered`.

## 4. Graphify

- [VERIFIED] Version installée et épinglée : `graphify --version` → `graphify 0.9.26`. Exécutable : `which graphify` → `/c/Users/hamio/.local/bin/graphify` (`graphify.exe`, binaire compilé). `graphify-mcp.exe` également présent au même emplacement.
- [DECLARED — `CAPTURE-2026-08-19-013315`, `DECISION-2026-08-18-004740-graphify-v1-architecture.md`] Installé **hors dépôt**, via `uv tool` : `uv tool install --system-certs "graphifyy[gemini]==0.9.26"`. [VERIFIED] confirmé indirectement : `uv tool list` → `graphifyy v0.9.26` (fournit les commandes `graphify`, `graphify-mcp`). Note de nommage : le paquet PyPI est `graphifyy` (deux `y`), la commande installée est `graphify`.
- [VERIFIED] `.env.example` → une seule variable : `GEMINI_API_KEY=`. Copier en `.env` (non versionné, exclu par `.graphifyignore` et par les motifs de secrets) et y placer la clé — jamais dans un fichier suivi par Git.
- [VERIFIED] Chargement en session (variable présente, valeur non affichée) : `set -a; source .env; set +a` puis `[ -n "$GEMINI_API_KEY" ] && echo "presente : oui"` → `presente : oui`. [DECLARED — `REPORT-2026-08-21-010520-021-executor-graph-connectivity-measurement.md:40`] : à recharger avant chaque commande `graphify`, l'état du shell ne persiste pas entre les appels d'outil.
- [VERIFIED] `.graphifyignore` (lu directement) exclut, par section : `graphify-out/` (sortie générée) ; deux sources supersédées explicitement listées ; `.git/` ; secrets et configuration locale (`.env`, `.env.*`, `*.key`, `*.pem`, `*.p12`, `*.pfx`, `credentials.*`, `secrets/`, `*.crt`, `*.dump`) ; dépendances/caches/temporaires (`node_modules/`, `.venv/`, `venv/`, `.cache/`, `__pycache__/`, `.pytest_cache/`, `*.tmp`, `*.temp`, `*.log`, `*.bak`, `*.swp`, `~$*`) ; `index.md` et `**/index.md` (redondants avec le graphe) ; configuration d'assistants et d'outils (`.claude/`, `.codex/`, `.cursor/`, `.agents/`, `CLAUDE.md`, `.gitattributes`) ; garde-fous et outillage (`.githooks/`, `tools/`) ; motifs de détection (`rules/patterns/`). La couche History/Evidence (Missions, Prompts, rapports) n'a pas besoin d'un motif d'exclusion : elle vit structurellement dans `workshop-build`, un autre dépôt.
- [VERIFIED] Commandes d'usage (sortie de `graphify --help`) :
  - `graphify extract <path> --backend gemini` : extraction complète (AST + sémantique LLM), incrémentale par défaut (cache de hash sémantique).
  - `graphify extract <path> --backend gemini --force` : re-scan complet, ignore le cache et le gate incrémental.
  - `graphify extract <path> --code-only` : indexe le code par AST local, sans clé API, **saute les fichiers doc/paper/image**.
  - `graphify update <path>` : re-extrait les fichiers code et met à jour le graphe, sans LLM (`--force` pour écraser même avec moins de nœuds).
  - `graphify cluster-only <path>` : rejoue le clustering sur un `graph.json` existant et régénère `GRAPH_REPORT.md` — gratuit, sans appel LLM pour la structure (un appel LLM optionnel pour nommer les communautés, sauf `--no-label`).
  - `graphify hook status` / `hook install` / `hook uninstall` : gestion des hooks Git.
  - `graphify query "<question>"`, `graphify path "A" "B"`, `graphify explain "X"` : navigation sur `graph.json` sans appel LLM.
- [DECLARED — `REPORT-2026-08-21-002914-020-C01…md:29`, `REPORT-2026-08-21-010520-021…md:84`] Sauvegardes datées : `graphify-out/YYYY-MM-DD/` (une copie horodatée du graphe conservée à côté du graphe courant).
- [DECLARED — `AUDIT-2026-08-20-000525-018…md:98`, `REPORT-2026-08-21-010520-021…md:18,117-119`] Coût indicatif d'une passe complète sur le corpus du Vault (24-26 documents, un seul chunk) : ~22-26k jetons entrée, ~4-5k jetons sortie, ~0,025-0,027 $ US, ~23-25 secondes. Une extraction partielle non forcée est nettement moins chère (~0,005 $, `REPORT-...020-C01...:64`).

## 5. Serveur MCP « workshops »

- [VERIFIED] Bloc de configuration lu dans le fichier de config de Claude Desktop (emplacement ci-dessous), **sans valeur sensible** :
  ```json
  "workshops": {
    "command": "mcp-server-filesystem",
    "args": ["C:\\Users\\hamio\\Workspaces\\workshops"]
  }
  ```
  Dossier exposé : `C:\Users\hamio\Workspaces\workshops` (racine contenant `vault` et `workshop-build`).
- [DECLARED — `HANDOFF-2026-08-20-231741-pilot-session-closure-decision-status-mcp.md:120-125`] Emplacement réel du fichier de configuration (l'installation Microsoft Store de Claude Desktop virtualise le chemin classique) : `%LOCALAPPDATA%\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\claude_desktop_config.json`. [VERIFIED] ce chemin exact existe sur ce poste (fichier trouvé et lu).
- [DECLARED — `CAPTURE-2026-08-19-013315`] Usage : le Pilot lit ses sources directement via ce serveur (lecture/écriture de fichiers). Le Pilot **ne lance jamais de commande Git** — voir §6.
- [DECLARED — `DECISION-2026-08-19-233650-graphify-integrations-amendment.md`, D5] La mise en service d'un serveur MCP Graphify (`graphify-mcp.exe`, présent mais non configuré ci-dessus) reste hors périmètre : à décider par une Mission distincte.

## 6. Rôles et sessions

- [DECLARED — `CAPTURE-2026-08-19-013315:64-74`] **Pilot** (Chat Advisor) : brainstorm, arbitrage, architecture, cadrage, rédaction des Missions et Prompts, review, passations. Accès MCP « workshops » en lecture/écriture de fichiers. Ne touche jamais le filesystem par une commande Git et ne lance pas de commande shell. Session : Claude Desktop.
- [DECLARED — `CAPTURE-2026-08-19-013315`] **Executor** : filesystem, Git, exécution, tests, mesures, preuves. Ne décide jamais l'architecture. Seul rôle à committer. Session : Claude Code, ouverte **dans `vault/`** uniquement.
- [DECLARED — `AGENTS.md:15`] **Owner** : seul rôle habilité à pousser (`git push`) et à accorder les human gates (secrets, mises à jour de version système, tout ce qui sort du périmètre autorisé d'une Mission).
- [DECLARED — `DECISION-2026-08-21-000236-execution-report-channel.md`] Missions et Prompts : `workshop-build/workshop-production/{missions,prompt-archive}`. Rapports d'exécution : `workshop-build/workshop-production/reports/`, un fichier par Mission, stagé avec le travail qu'il prouve. Audits, captures, proposals, handoffs, decisions : voir les dossiers correspondants dans les deux dépôts.

## 7. Vérification de bon fonctionnement

Une commande et son résultat attendu, par composant :

| Composant | Commande | Résultat attendu |
|---|---|---|
| Git | `git status -sb` | branche courante, aucune divergence inattendue |
| Hooks | `graphify hook status` | `post-commit: installed`, `post-checkout: installed`, `merge driver: registered` |
| Graphify (version système) | `graphify --version` | `graphify 0.9.26` — ne doit **jamais** dévier sans Decision explicite |
| Clé Gemini | `set -a; source .env; set +a && [ -n "$GEMINI_API_KEY" ] && echo oui` | `oui`, sans jamais afficher la valeur |
| MCP « workshops » | lecture d'un fichier connu du Vault depuis le Pilot | contenu retourné sans erreur |
| Graphe | `graphify query "<question>"` sur `graphify-out/graph.json` | sous-graphe pertinent renvoyé, pas d'erreur de fichier manquant |
| Contrôle de liens | `bash tools/check-links.sh` sur un `.md` stagé sans section `## Liens` | `exit 1`, message `LIENS: section manquante: <fichier>` |

## 8. Outillage d'état, journal, index et recherche (Missions 027 et 029)

Cinq scripts créés en Mission 027, deux modifiés en Mission 029, plus trois gabarits. Tous dans `tools/` (scripts) et `templates/` (gabarits) ; aucun n'appelle de modèle.

- [VERIFIED] `tools/append-journal.sh <chemin-projet> "<texte>"` : ajoute une ligne horodatée en fin de `<projet>/state/journal.md`, création du fichier et du dossier si absents. N'ouvre jamais le journal en lecture. Convention de tags reconnue en préfixe du texte, ratifiée par la [Decision du 2026-08-23 14:35](../decisions/DECISION-2026-08-23-143542-pilot-contract-superseded-marking-and-journal-tags-ratification.md) : `ETAT:` et `PROCHAIN:` (dernière occurrence retenue), `OUVERT:` (toutes les occurrences listées), `REPRISE:` (reconnue seulement en dernière ligne du journal). Une ligne sans tag reconnu n'alimente aucune rubrique de la fiche d'état.
- [VERIFIED] `tools/build-state.sh <chemin-projet>` : régénère `<projet>/state/STATE.md` à partir du journal, de l'état Git des deux dépôts et du listing des documents récents (mtime, 15 derniers). Fiche générée, jamais éditée à la main. Depuis Mission 029, la fiche s'ouvre par le **contrat du Pilot** (sept lignes), recopié tel quel depuis `templates/pilot-contract-template.md` (repères `CONTRACT:BEGIN`/`CONTRACT:END`), sous la ligne d'en-tête « fichier généré ». Plafond arbitré : sept lignes exactement — le script échoue (`exit 1`, message explicite, fiche non écrite) si le gabarit s'en écarte. Mesuré sur `workshop-production` : ~2,5–2,8 s par exécution, idempotent (deux exécutions consécutives sans événement entre les deux produisent un `md5sum` identique).
- [VERIFIED] `tools/build-indexes.sh <racine...>` : régénère un `index.md` par dossier éligible sous chaque racine passée en argument (élagage `.git`, `tools`, `state`, `graphify-out`, etc. — voir `PRUNE_NAMES` dans le script). Depuis Mission 029, lit aussi le champ front-matter `supersedes` de tout le corpus de la racine traitée (valeur scalaire ou liste YAML indentée, tolérant les deux formats rencontrés dans le corpus) et : (a) suffixe `— REMPLACÉ par <fichier>` l'entrée de chaque fichier cité, dans l'`index.md` de son dossier ; (b) écrit `<racine>/superseded-files.txt`, une liste plate (chemin relatif à la racine, un par ligne) des fichiers remplacés sous cette racine — emplacement choisi par l'Executor, documenté dans le [rapport de la Mission 029](../../workshop-build/workshop-production/reports/). Mesuré : ~3 s sur la racine Vault, ~8 s sur `workshop-production` (165 fichiers `.md`), sous le seuil de dix secondes.
- [VERIFIED] `tools/find-in-vault.sh [--root <dir>] [--limit N] [--frontmatter-only] <motif>` : recherche par contenu, renvoie les lignes trouvées (jamais les fichiers), format `chemin:ligne:texte`. Racine par défaut : répertoire courant de l'appelant, **pas** un chemin fixe vers le Vault — défaut non corrigé, resté `OPEN` depuis Mission 027 (hors périmètre de Mission 029). Depuis Mission 029, suffixe `[REMPLACÉ]` toute ligne dont le fichier source figure dans un `superseded-files.txt` trouvé sous la racine de recherche (recherche récursive, pas seulement à la racine stricte, pour rester correct malgré le défaut de racine ci-dessus) ; absence de liste tolérée, sans erreur ; la ligne est toujours renvoyée, jamais filtrée. La marque n'est fraîche qu'à la dernière génération des index par `build-indexes.sh` : un `supersedes` ajouté après coup n'apparaît qu'après régénération.
- [VERIFIED] `tools/write-marker.sh` : écrit `VAULT-ROOT.md` à la racine de travail depuis `templates/vault-root-template.md` — fichier marqueur remonté, retrouvé en remontant les dossiers parents (même principe que la détection d'un dépôt Git par `.git`). Non versionné (racine de travail, hors des deux dépôts).
- [VERIFIED] `templates/pilot-contract-template.md` : source unique des sept lignes du contrat du Pilot, recopiées telles quelles par `build-state.sh`. Repères `CONTRACT:BEGIN`/`CONTRACT:END` délimitent le bloc extrait ; le plafond de sept lignes y est contrôlé, pas rédigé dans un script.
- [VERIFIED] `templates/session-opening-prompt-template.md` : prompt de réouverture minimal (rôle, chemin de la fiche d'état, emplacement des blocs RELAY) — aucune règle de comportement, elle vit dans la fiche d'état via le contrat ci-dessus.
- [VERIFIED] `templates/vault-root-template.md` : gabarit du fichier marqueur écrit par `write-marker.sh`.

## 9. Historique

- **2026-08-18** — Mission Graphify V1 : installation initiale, version épinglée 0.9.26 [DECLARED — `DECISION-2026-08-18-004740-graphify-v1-architecture.md`].
- **2026-08-18/19, Mission 018** — Consolidation du corpus et propagation des garde-fous ; motifs d'exclusion `.graphifyignore` étendus (secrets, configs d'assistants, `rules/patterns/`) [DECLARED — `AUDIT-2026-08-20-000525-018…`].
- **2026-08-19** — Amendement Graphify V1 : activation des intégrations natives (hooks `post-commit`/`post-checkout` autorisés, MCP Graphify évalué mais non activé) [DECLARED — `DECISION-2026-08-19-233650-graphify-integrations-amendment.md`].
- **2026-08-19** — Accès MCP « workshops » ouvert pour le Pilot (serveur `mcp-server-filesystem`) [DECLARED — `HANDOFF-2026-08-20-231741...`].
- **2026-08-20, Mission 020/020-C01** — Restauration du graphe sémantique ; blocage constaté : clé Gemini absente de la session (`GEMINI_API_KEY or GOOGLE_API_KEY` requis), reprise par rechargement depuis `.env` ; canal de rapport d'exécution institué (`reports/`) [DECLARED — `REPORT-2026-08-20-235859-020…`, `REPORT-2026-08-21-002914-020-C01…`, `DECISION-2026-08-21-000236-execution-report-channel.md`]. Le mode de chargement de la clé utilisé avant cette régression (Mission 018) n'a pas été retrouvé dans les sources lues — écart documenté, non comblé par cette Mission.
- **2026-08-21, Mission 021** — Mesure : les liens Markdown littéraux ne produisent pas systématiquement d'arête `references` dans l'installation 0.9.26 (avertissement « 32 issues, Edge … missing required field 'source_file' ») [DECLARED — `REPORT-2026-08-21-010520-021…`].
- **2026-08-21, Mission 022** — Runbook V1 créé ; sa maintenance décidée. Environnement Python isolé (`venv` sous `%TEMP%`) créé et **détruit en fin de Mission** pour mesurer la version courante de Graphify à côté de la 0.9.26 du système, sans aucune modification du système. Voir le [tableau du volet B](../../workshop-build/workshop-production/reports/REPORT-2026-08-21-110049-022-executor-link-mechanism-and-runbook.md) pour le résultat. Contrôle `graphify --version` = 0.9.26 ajouté à la section Vérification (§7).
- **2026-08-21, Mission 023, volet A (présente Mission)** — [Standard de liens entre documents](../rules/RULES-2026-08-21-115658-document-linking-standard.md) gravé (règle, Decision, section `## Liens` sur les six gabarits et un gabarit de rapport créé). Contrôle `tools/check-links.sh` ajouté au `pre-commit`, éprouvé par un essai qui échoue (fichier fautif) avant mise en service.
- **2026-08-21, Mission 023, volet B** — Hypothèse de 022 (cache responsable des arêtes `references` manquantes) testée : `graphify-out/cache/` vidé puis `graphify update .` (sans modèle) et `graphify cluster-only`. **Verdict négatif** : les six gabarits restent isolés (degré 0) après le rebâti, malgré leur nouvelle section `## Liens` sur disque au moment du rebâti. Aucune procédure gravée ici — voir le [tableau du volet B](../../workshop-build/workshop-production/reports/REPORT-2026-08-21-120543-023-executor-linking-standard-and-ast-rebuild.md) pour la mesure complète et l'hypothèse retenue (syntaxe de repère `<chevrons>` dans la seconde ligne des gabarits).
- **2026-08-21, Mission 024, volet A** — Test croisé sur copies isolées sous `$TEMP` (corpus minimal à quatre cas, puis copie complète du Vault, avant/après retrait de la ligne à chevrons). **H1 infirmée et H2 infirmée** sur les deux mesures : la ligne à chevrons ne fait perdre aucune arête, et les liens `../` entre dossiers résolvent (`context-lifecycle-v2.md` → 5/5 gabarits du cycle, sur une copie fraîche sans cache). Écart noté (H3, non tranché) : le graphe déjà sur disque dans le Vault réel (hook post-commit du commit `44f8a0f`, cache non vidé) reste à degré 0 pour les mêmes gabarits — la copie et le Vault réel ne partent pas du même état de cache ; la mesure post-commit de cette Mission tranche pour de vrai. Voir le [rapport 024](../../workshop-build/workshop-production/reports/REPORT-2026-08-21-134416-024-executor-link-resolution-and-retroactive-linking.md) pour les deux tableaux.
- **2026-08-21, Mission 024, volet B** — Ligne à remplir des sept gabarits remplacée par un texte non-lien (`(à compléter : type — titre — chemin relatif, voir le standard de liens)`), quel que soit le verdict H1 : un lien mal formé reste un défaut. Gabarit de rapport durci (§3 Commits, §7 Remesure finale) : plus d'emplacement `<rempli après commit>` ambigu, consigne explicite de mesurer avant staging.
- **2026-08-21, Mission 024, volet C** — Retouche rétroactive de huit documents cités par la carte des liens manquants du [rapport 021](../../workshop-build/workshop-production/reports/REPORT-2026-08-21-010520-021-executor-graph-connectivity-measurement.md) (§10/§5) : liens ajoutés en contexte là où le nom était déjà cité, section `## Liens` typée sur chacun, ligne inverse `amendé par` posée sur la cible d'un `amende` déjà déclaré en front-matter. Détail complet dans le rapport 024.
- **2026-08-21, Mission 025** — Mesure décisive, une seule configuration jamais testée jusqu'ici : `graphify-out/` déplacé hors dépôt, une seule passe `graphify extract . --backend gemini` puis `graphify cluster-only` sur dossier vierge. **Issue 2 désignée par le critère écrit d'avance** (M2 et M3 mauvais sur dossier vierge) : Graphify est retiré du rôle « graphe du Vault » ; Decision formelle à rédiger par le Pilot sur le rapport, non prise ici. Chiffres : M1 24 nœuds, seuil 30-120 non atteint, les 7 gabarits (`templates/*`) absents du graphe (avertissement outil : « 7/31 dispatched file(s) produced no nodes ») · M2 0/5 · M3 3/8 · M4 1 isolé lié · M5 A PARTIAL, B PARTIAL, C FAIL, D INSUFFICIENT. Aucune procédure de reconstruction propre n'est gravée ci-dessous : le résultat mesuré ne le justifie pas. Voir le [rapport 025](../../workshop-build/workshop-production/reports/REPORT-2026-08-21-145101-025-executor-clean-graph-rebuild-decision.md) pour la mesure complète.
- **2026-08-23, Mission 027 — Lot A** — Journal en ajout seul, fiche d'état générée, index générés par dossier, recherche par contenu, fichier marqueur de racine : cinq scripts créés (`append-journal.sh`, `build-state.sh`, `build-indexes.sh`, `find-in-vault.sh`, `write-marker.sh`) et un gabarit (`vault-root-template.md`), voir §8. Exclusion `index.md` levée dans `.graphifyignore` pour que les index entrent au graphe. Convention de tags du journal introduite sans spécification (`OPEN 2` de son rapport) — ratifiée en Mission 029, voir ci-dessous. Runbook non mis à jour dans ce commit (`OPEN 3` de son rapport) — comblé par la présente entrée. Voir le [rapport 027](../../workshop-build/workshop-production/reports/REPORT-2026-08-23-132241-027-executor-state-journal-indexes-search-and-marker.md).
- **2026-08-23, Mission 029** — Contrat de comportement du Pilot déplacé de la prose (Decisions non lues à l'ouverture) vers la fiche d'état elle-même, générée : `templates/pilot-contract-template.md` créé, sept lignes plafonnées, contrôle logiciel dans `build-state.sh`. Marquage des documents remplacés : `build-indexes.sh` lit `supersedes` et écrit `superseded-files.txt` par racine ; `find-in-vault.sh` suffixe `[REMPLACÉ]` sans jamais filtrer. Prompt d'ouverture réduit à trois éléments (`session-opening-prompt-template.md`), sans règle de comportement. Convention de tags du journal (Mission 027) ratifiée par [Decision](../decisions/DECISION-2026-08-23-143542-pilot-contract-superseded-marking-and-journal-tags-ratification.md). Mesures : `build-state.sh` idempotent (~2,7 s) ; `build-indexes.sh` ~3 s (Vault, 2 fichiers marqués) et ~8 s (`workshop-production`, 17 fichiers marqués) ; `find-in-vault.sh MiroShark` depuis `workshop-build` : 30/50 lignes marquées au défaut (`--limit 50`), 31/97 lignes marquées sans plafond — toutes issues des captures 011200 et 012300. Voir le rapport de la Mission 029 dans `workshop-build/workshop-production/reports/`.
- **2026-08-24, Mission 039** — Préflight de session, lanceur d'identité, muraille pre-commit : voir §10. Runbook mis à jour dans ce commit, conformément à l'obligation de mise à jour (en-tête de ce document) — signalée en écart par le rapport 039, comblée par la présente entrée (rangement de clôture). Voir le [rapport 039](../../workshop-build/workshop-production/reports/REPORT-2026-08-24-001819-039-executor-session-preflight-and-commit-wall.md).

## 10. Préflight de session, lanceur d'identité et muraille pre-commit (Mission 039)

- [VERIFIED] `tools/session-preflight.sh` : vérifie sans rien modifier — charte des rôles présente, pointeurs `AGENTS.md`/`CLAUDE.md` des deux dépôts, `.claude/settings.json` présent et JSON valide, rôle par sonde de capacité, outils attendus exécutables (`git`, `bash`, `tools/build-state.sh`, `tools/build-indexes.sh`, `tools/check-links.sh`), âge de `.claude/hooks.log` s'il existe (silence > 72h signalé). Sortie `READY` ou `NOT-READY: <n> issue(s)` ; écrit le tampon local `.claude/.preflight_stamp.json` (non versionné, exclu par `.gitignore`). Bug réel rencontré et corrigé en route : la validation JSON priorise désormais `node`, car `python3` sur ce poste peut n'être qu'un alias-stub Windows Store sans interpréteur réel (faussait un `NOT-READY` sur un `settings.json` en réalité valide).
- [VERIFIED] Câblé au hook `SessionStart` (`tools/session-start-role.sh`) : silence si `READY` (les quatre lignes de rôle inchangées), une ligne `Preflight NOT-READY: <n> issue(s), see .claude/.preflight_stamp.json` sinon.
- [VERIFIED] `tools/start-executor.sh` : lanceur d'identité V1 minimal — pose `VAULT_AGENT=executor` et `VAULT_ROOT`, affiche un rappel d'une ligne (rôle et interdits), lance `claude` depuis la racine du Vault. Aucune table d'agents, aucun clone-vitre.
- [VERIFIED] Muraille pre-commit : les deux dépôts (`vault/.githooks/pre-commit`, `workshop-build/.githooks/pre-commit`) refusent tout commit si le tampon (`vault/.claude/.preflight_stamp.json`, référencé par chemin relatif depuis `workshop-build`) est absent, `ready: false`, ou vieux de plus de 24h. Message de refus à remède unique : `bash tools/session-preflight.sh`, aucune variable de contournement. Refus et passage prouvés par le feu dans les deux dépôts.

## Liens

- `prescrit par` — [Runbook d'installation du Vault — registre vivant](../decisions/DECISION-2026-08-21-105117-vault-installation-runbook.md)
- `voir aussi` — [Standard de liens entre documents](../rules/RULES-2026-08-21-115658-document-linking-standard.md)
