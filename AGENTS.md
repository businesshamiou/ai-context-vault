# Instructions pour les agents

Before any action: determine your role. Read [the role charter](./rules/RULES-2026-08-23-224706-role-charter-and-session-determination.md).

- Les fichiers du Vault sont la source de vérité. Lire les sources liées avant toute modification.
- Rédiger la prose en français. Utiliser un anglais idiomatique pour les identifiants machine, slugs, clés et noms de dossiers.
- Enregistrer explicitement toute décision structurante. Ne jamais transformer silencieusement une proposition en décision.
- Appliquer le [cycle de contexte V2](./rules/RULES-2026-08-17-111018-context-lifecycle-v2.md) de façon sélective : capturer seulement ce qui sera durablement utile et créer une proposal uniquement lorsqu'une option importante doit attendre un arbitrage.
- Appliquer la [règle de versionnement des Missions et outputs générés](./rules/RULES-2026-08-17-211522-mission-versioning-and-generated-output.md) lorsqu’un projet utilise des Missions ou une landing zone `generated/`.
- Maintenir le fichier `current-state.md` lorsqu’un projet l’utilise ; le mettre à jour au lieu d’empiler des états successifs.
- Produire un handoff seulement lorsqu’une reprise fiable est réellement nécessaire.
- Conserver toute décision structurante au statut `PROPOSED` jusqu’à son arbitrage par human gate.
- Ne jamais écrire de secret, clé, token, mot de passe ou credential dans le Vault ou dans Git.
- Des hooks Git contrôlent les secrets et les motifs de contournement ; ils s’activent par `core.hooksPath` pointant sur `.githooks/`. Cette configuration est locale et non versionnée : la refaire après tout clone.
- Inspecter chaque fichier avant staging, stage fichier par fichier, puis inspecter le diff staged.
- Remesurer l'état technique et les preuves au moment utile au lieu de recopier des valeurs périssables.
- Ne jamais push automatiquement. Exiger un human gate pour tout push, suppression importante, renommage structurant, partage sensible ou autre action sensible.
- Maintenir la frontière entre le Vault et les projets externes : le Vault contient le transversal ; chaque projet conserve son contexte local.
- Ne jamais importer automatiquement dans le Vault le contexte métier, les décisions ou les artefacts propres à un projet.
- Toute amélioration transversale issue d’un projet doit être validée avant son intégration au Vault.
- Ne pas introduire dans le Vault les prompts, présentations, storyboards, supports ou outils dont le seul rôle est de fabriquer le workshop.
- Tout rapport d'exécution de l'Executor est un fichier dans `../workshop-build/workshop-production/reports/` (Decision du 2026-08-21) ; en chat, deux lignes : chemin du rapport et ligne « gates ».
- L'installation du Vault est décrite dans [le runbook](./knowledge/runbook-vault-setup.md) ; toute Mission qui installe, configure, met à jour ou retire un composant le met à jour dans le même commit.
- Tout document porte une section `## Liens` conforme au [standard de liens](./rules/RULES-2026-08-21-115658-document-linking-standard.md) ; le contrôle `tools/check-links.sh` tourne au pre-commit.
- Toute délégation à l'Executor suit la [règle du relais entre rôles par mini-prompts](./rules/RULES-2026-08-23-124937-role-relay-mini-prompts.md) : mini-prompt à l'aller, bloc `RELAY` en fin de rapport au retour.

## Liens

- `applique` — [Cycle de contexte V2](./rules/RULES-2026-08-17-111018-context-lifecycle-v2.md)
- `applique` — [Standard de liens entre documents](./rules/RULES-2026-08-21-115658-document-linking-standard.md)
- `applique` — [Relais entre rôles par mini-prompts à rubriques fixes](./rules/RULES-2026-08-23-124937-role-relay-mini-prompts.md)
