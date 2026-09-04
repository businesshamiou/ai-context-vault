---
type: index
title: "Index — decisions"
description: "Index généré automatiquement par tools/build-indexes.sh."
status: active
generated_by: tools/build-indexes.sh
---

# Index — decisions

Index généré automatiquement. Ne pas éditer à la main : régénérer via `tools/build-indexes.sh`.

## Contenu

- `DECISION-2026-08-17-003000-vault-central-architecture.md` — Architecture centrale — Vault permanent et projets frères · decision · active
- `DECISION-2026-08-17-111018-vault-v1-information-architecture.md` — Architecture d'information V1 — primitives, preuves et human gates · decision · active
- `DECISION-2026-08-18-004740-graphify-v1-architecture.md` — Architecture Graphify V1 — navigation optionnelle et corpus actif borné · decision · active
- `DECISION-2026-08-19-115306-adopt-okf-knowledge-format.md` — Adoption du format OKF comme norme de référence · decision · active
- `DECISION-2026-08-19-115306-project-registry-v1.md` — Project Registry V1 — architecture et contrat d'écriture · decision · active
- `DECISION-2026-08-19-233650-graphify-integrations-amendment.md` — Amendement Graphify V1 — activation des intégrations natives · decision · ARBITRATED
  - Lève l'exclusion des hooks et du MCP, retient le mode par défaut et exclut le mode strict.
- `DECISION-2026-08-20-015748-mission-status-field-semantics.md` — Sémantique du champ status — front-matter Mission et registre · decision · ARBITRATED
  - Fige le status du front-matter Mission à l'autorisation de création ; MISSION-INDEX.md devient seule source de l'état d'exécution.
- `DECISION-2026-08-21-000236-execution-report-channel.md` — Canal de rapport d'exécution — type report, dossier reports/ · decision · ARBITRATED
  - Institue un rapport d'exécution en fichier, type report, dans workshop-production/reports/, stagé avec le travail qu'il prouve.
- `DECISION-2026-08-21-105117-vault-installation-runbook.md` — Runbook d'installation du Vault — registre vivant, obligation de mise à jour par les Missions · decision · ARBITRATED
  - Institue le runbook d'installation, sa qualification VERIFIED/DECLARED ligne par ligne, et l'obligation pour toute Mission d'installation de le mettre à jour dans le même commit.
- `DECISION-2026-08-21-115658-document-linking-standard.md` — Adoption du standard de liens entre documents · decision · ARBITRATED
- `DECISION-2026-08-23-124848-seven-arbitrations-2026-08-23.md` — Sept arbitrages de session du 2026-08-23 · decision · ARBITRATED
- `DECISION-2026-08-23-124917-scope-obsidian-and-content-search.md` — Décisions de périmètre — Obsidian hors du premier workshop, recherche par contenu construite en propre · decision · ARBITRATED
- `DECISION-2026-08-23-124937-role-relay-mini-prompts.md` — Adoption de la règle du relais entre rôles par mini-prompts · decision · ARBITRATED
- `DECISION-2026-08-23-143542-pilot-contract-superseded-marking-and-journal-tags-ratification.md` — Contrat du Pilot, marquage des documents remplacés, et ratification de la convention de tags du journal · decision · ARBITRATED
- `DECISION-2026-08-23-155831-relay-forward-snippet-and-superseded-list-graph-exclusion.md` — Sens aller du relais en snippet, et liste des remplacés hors graphe mais versionnée · decision · ARBITRATED
- `DECISION-2026-08-23-180500-relay-summary-rubric.md` — Rubrique « Résumé » dans le bloc RELAY du sens retour · decision · ARBITRATED
- `DECISION-2026-08-23-184200-graphify-graph-role-withdrawal.md` — Retrait de Graphify du rôle « graphe du Vault » · decision · ARBITRATED
- `DECISION-2026-08-23-220049-piv-taxonomy-and-english-system-language.md` — Taxonomie PIV, langue système anglaise, charte des rôles, fin des fichiers PROMPT · decision · ARBITRATED
- `DECISION-2026-08-24-214607-transverse-mechanism-distribution.md` — Distribution des mécanismes transverses — doctrine unique, implémentation épinglée, adaptateur local · decision · ARBITRATED
- `DECISION-2026-08-25-110935-journal-close-tag-and-keyed-doors.md` — Extension de la convention de tags du journal — tag CLOSE: et portes à clé · decision · ARBITRATED
- `DECISION-2026-08-25-131034-doctrinal-arbitrations-2026-08-25.md` — Arbitrages doctrinaux du 2026-08-25 — révocation du shell Pilot, auto-rangement, références de session, anglicisation du vocabulaire de liens · decision · ARBITRATED
- `DECISION-2026-08-26-154553-delegated-push-exception-becomes-rule.md` — Amendement — le push délégué devient une règle : valide si et seulement si autorisation Owner verbatim datée · decision · arbitrated
  - Grave l'exception de push délégué (deux occurrences le 2026-08-26, RELAY PUSH-061 et PUSH-062) en règle permanente : le push exécuté par l'Executor sous instruction ponctuelle n'est valide que si le mini-prompt porte la ligne d'autorisation Owner verbatim, datée.
- `DECISION-2026-08-26-163958-stage2-mcp-allowlist-status-quo.md` — Arbitrage d — étage 2 (allowlist d'écriture MCP) en statu quo documenté, trois conditions de réveil · decision · arbitrated
  - Grave l'arbitrage Owner « d » : l'allowlist d'écriture MCP côté Pilot n'a pas de voie native satisfaisante (Mission 063, confirmé par le rapport du Vault aîné) ; l'étage 3 reste la protection en vigueur ; trois conditions de réveil nommées, aucune portée effective.
- `DECISION-2026-08-26-231617-one-authorization-line-one-gesture.md` — Amendement — une ligne d'autorisation Owner couvre un seul geste · decision · arbitrated
  - Amende DECISION-154553 (push délégué) : une ligne d'autorisation Owner verbatim ne couvre jamais plus d'un geste ; toute fusion de gestes dans une même ligne vaut refus des gestes fusionnés ; le gabarit se vérifie avant l'exécution, fail closed.
- `DECISION-2026-08-27-100016-copy-protocol-snippets-and-destinations.md` — Protocole de copie — sens retour en snippet, mots exacts groupés et adressés, ligne d'identité étendue aux instructions ponctuelles · decision · arbitrated
  - Grave quatre correctifs du protocole de copie Owner/Pilot/Executor : le bloc RELAY du sens retour livré en snippet copiable d'un seul geste, les mots exacts du Pilot livrés en snippets groupés en fin de tour, chaque snippet destiné à l'Owner nommant sa fenêtre de destination, et la ligne d'identité 'Tu es l'Executor — Mission <NNN>' étendue aux instructions ponctuelles sous la forme 'Tu es l'Executor — instruction ponctuelle (<description courte>)'.
- `DECISION-2026-08-27-112528-delegated-push-exception-covers-its-journal-commit.md` — Amendement — l'exception de push délégué couvre le commit de sa propre ligne de journal · decision · arbitrated
  - Amende DECISION-154553 : l'exception de push délégué autorise désormais l'écriture ET le commit de sa ligne de journal, rien d'autre ; le périmètre des gestes reste inchangé pour tout le reste.
- `DECISION-2026-08-28-203627-link-section-requirement-scoped-to-corpus.md` — Bornage du standard de liens — la section ## Liens obligatoire s'applique au corpus du Vault, pas au matériel adopté de skills/external/ · decision · arbitrated
  - Grave l'arbitrage X de l'Owner : l'obligation de section ## Liens du standard de liens est bornée au corpus documentaire du Vault et ne s'applique pas aux fichiers de vault/skills/external/, matériel opérationnel adopté dont les corps restent verbatim ; la vérification de résolution des liens reste globale, y compris dans external/. check-links.sh est ajusté en conséquence, preuves par canaris.
- `DECISION-2026-08-28-205904-amendment-lives-in-amended-repo.md` — Principe de placement des amendements — une Décision d'amendement vit dans le dépôt du document qu'elle amende · decision · arbitrated
  - Grave l'arbitrage M de l'Owner : toute Décision portant une relation amends ou supersedes vers un document se dépose dans le dépôt de ce document, jamais dans le dépôt frère. Les relations d'amendement restent ainsi internes au graphe de chaque dépôt, calculables par les gardiens, et la chaîne d'amendement du produit distribué ne contient jamais de lien mort. Résout la tension cross-dépôt révélée par la Mission 085 sans toucher ni au standard de liens ni aux gardiens.
- `DECISION-2026-08-29-110852-deletion-is-owner-gesture-trash-zone.md` — La suppression définitive est un geste Owner — le déplacement hors dépôts en est le substitut agent · decision · arbitrated
  - Grave le fait mesuré trois fois par la Mission 087 : aucun agent, Pilot ou Executor, ne supprime définitivement un fichier, même sous human gate accordé — la politique de l'environnement le refuse, et le refus n'est pas contournable. La suppression rejoint le push parmi les gestes réservés à l'Owner. Substitut agent : déplacer le fichier vers une zone de dépôt hors de tout dépôt (_trash à la racine de l'espace de travail), que l'Owner seul vide. Amende la charte des rôles (§2, §3), la règle du relais (rubrique 4 et sens retour) et le gabarit de Mission (aucune étape de suppression Executor) ; AGENTS.md distingue gestes Owner et human gates.
- `DECISION-2026-08-29-212009-evidence-status-and-stop-control.md` — Statut de preuve des lignes d'arbitrage et contrôle d'arrêt obligatoire sur toute affirmation non lue · decision · arbitrated
  - Toute ligne soumise à l'arbitrage de l'Owner déclare son statut de preuve — mesurée, hypothèse ou jugement — et tout point de Décision affirmant le contenu d'un document non lu dans la session part avec un contrôle d'arrêt nommé dans sa Mission d'exécution.
- `DECISION-2026-08-30-013217-mission-frozen-at-snippet-emission.md` — Amendement — un fichier de Mission est gelé dès l'émission de son snippet · decision · arbitrated
  - Une Mission ne se retouche plus en place à partir du moment où son mini-prompt est remis à l'Owner : le Pilot ne peut pas observer quand une fenêtre Executor s'ouvre, donc l'émission du snippet est le seul instant de gel observable ; toute évolution passe par une correction Cxx et un nouveau snippet.
- `DECISION-2026-09-02-191407-journal-and-index-as-pointers-300-chars.md` — Décision — Journal et index en pointeurs : toute ligne ≤ 300 caractères, le récit vit dans le document pointé · decision · active
  - Toute ligne future du journal et des index de Missions est un pointeur (date, tag, une phrase, nom du fichier) plafonnée à 300 caractères ; le détail vit dans le rapport, la capture ou le handoff pointé. Applicable par gardien.
- `DECISION-2026-09-03-140714-pilot-context-budget-mission-size-cap.md` — Budget de contexte du Pilot : plafond de taille des Missions sur distribution mesurée, ordre d'ouverture digest → handoff → refs, dryRun comme mesure, snippet émis une fois · decision · arbitrated
  - Décision arbitrée le 2026-09-03 (gate « plafonne ») : un plafond fail-closed sur la taille des fichiers MISSION dont la valeur ne sera fixée qu'après mesure de la distribution existante ; quatre règles doctrinales de parcimonie côté Pilot ; une HYPOTHÈSE nommée sur le préfixe fixe de conversation et sa seule mesure possible.
- `DECISION-2026-09-03-230604-one-mcp-window-per-workspace-skills-fully-exposed.md` — Une fenêtre MCP, un workspace ; skills exposés en entier · decision · arbitrated
  - Décision arbitrée le 2026-09-03 (ordre Owner, session Pilot) : un seul serveur MCP filesystem configuré une fois au niveau de l'application Desktop, racine = le workspace entier, fenêtre unique de toute session de chat vers les fichiers ; l'installation comprend ce MCP et les skills exposés au chat ; par défaut la liste entière des skills du projet est exposée à la session de chat, sous une HYPOTHÈSE de coût à mesurer avant toute réduction ; la liste des skills à installer se dérive de l'index des skills du Vault, jamais écrite à la main.
- `DECISION-2026-09-04-121443-existence-sweep-memory-hypothesis-measured-existing.md` — Balayage d'existence avant toute recommandation de création ; la mémoire n'est jamais source d'hypothèse ; rubrique « Existant mesuré » au gabarit de Mission · decision · arbitrated
  - Décision arbitrée le 2026-09-04 après un angle mort mesuré : le Pilot a recommandé de créer un fichier d'entrée qui existait déjà, et l'Owner a arbitré « go » avant qu'aucun contrôle ne joue. Trois points : toute recommandation de création porte, dans la même réponse, un balayage d'existence ; la règle « la mémoire n'est jamais une source d'état » s'étend aux hypothèses sur ce qui existe ; le gabarit de Mission reçoit une rubrique obligatoire « Existant mesuré », avec gardien, pour toute Mission qui crée un fichier.

## Liens

- `prescribed by` — [Standard de liens entre documents](../rules/RULES-2026-08-21-115658-document-linking-standard.md)
