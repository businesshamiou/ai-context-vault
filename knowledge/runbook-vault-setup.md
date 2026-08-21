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
  - `pre-commit`, `pre-push`, `commit-msg` : garde-fous (contrôle de secrets — voir `tools/check-secrets.sh`, qui refuse par défaut si `rules/patterns/secret-patterns.txt` est introuvable).
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

## 8. Historique

- **2026-08-18** — Mission Graphify V1 : installation initiale, version épinglée 0.9.26 [DECLARED — `DECISION-2026-08-18-004740-graphify-v1-architecture.md`].
- **2026-08-18/19, Mission 018** — Consolidation du corpus et propagation des garde-fous ; motifs d'exclusion `.graphifyignore` étendus (secrets, configs d'assistants, `rules/patterns/`) [DECLARED — `AUDIT-2026-08-20-000525-018…`].
- **2026-08-19** — Amendement Graphify V1 : activation des intégrations natives (hooks `post-commit`/`post-checkout` autorisés, MCP Graphify évalué mais non activé) [DECLARED — `DECISION-2026-08-19-233650-graphify-integrations-amendment.md`].
- **2026-08-19** — Accès MCP « workshops » ouvert pour le Pilot (serveur `mcp-server-filesystem`) [DECLARED — `HANDOFF-2026-08-20-231741...`].
- **2026-08-20, Mission 020/020-C01** — Restauration du graphe sémantique ; blocage constaté : clé Gemini absente de la session (`GEMINI_API_KEY or GOOGLE_API_KEY` requis), reprise par rechargement depuis `.env` ; canal de rapport d'exécution institué (`reports/`) [DECLARED — `REPORT-2026-08-20-235859-020…`, `REPORT-2026-08-21-002914-020-C01…`, `DECISION-2026-08-21-000236-execution-report-channel.md`]. Le mode de chargement de la clé utilisé avant cette régression (Mission 018) n'a pas été retrouvé dans les sources lues — écart documenté, non comblé par cette Mission.
- **2026-08-21, Mission 021** — Mesure : les liens Markdown littéraux ne produisent pas systématiquement d'arête `references` dans l'installation 0.9.26 (avertissement « 32 issues, Edge … missing required field 'source_file' ») [DECLARED — `REPORT-2026-08-21-010520-021…`].
- **2026-08-21, Mission 022 (présente Mission)** — Runbook V1 créé ; sa maintenance décidée. Environnement Python isolé (`venv` sous `%TEMP%`) créé et **détruit en fin de Mission** pour mesurer la version courante de Graphify à côté de la 0.9.26 du système, sans aucune modification du système. Voir le [tableau du volet B](../../workshop-build/workshop-production/reports/REPORT-2026-08-21-110049-022-executor-link-mechanism-and-runbook.md) pour le résultat. Contrôle `graphify --version` = 0.9.26 ajouté à la section Vérification (§7).
