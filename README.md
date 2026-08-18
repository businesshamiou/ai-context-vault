# Vault

Le Vault est la mémoire durable et le système opératoire transversal utilisé pour travailler avec l’IA. Les conversations, les sessions et les agents peuvent changer ; les fichiers du Vault conservent les règles et les méthodes qui doivent durer.

## Pourquoi il existe

Le Vault permet de posséder, versionner, relier et reprendre la connaissance générale nécessaire à une collaboration fiable avec des agents. Les fichiers restent la source de vérité ; les outils gravitent autour d’eux.

## Ce qui appartient au Vault

- règles et conventions transversales ;
- méthodes de capture, de décision, de handoff et de reprise ;
- pratiques Git et règles de sécurité ;
- skills et templates réellement réutilisables ;
- connaissances générales et apprentissages généralisables validés ;
- décisions propres à l’architecture et au fonctionnement du Vault.

## Ce qui appartient aux projets externes

Chaque projet reste dans un dossier ou dépôt frère, à l’extérieur du Vault. Il conserve ses objectifs, son état courant, ses décisions, sa connaissance métier, ses documents, ses sketches et ses handoffs.

La fabrication du workshop — prompts de production, présentation, storyboard, supports pédagogiques, journaux et outils de production — appartient elle aussi à un espace externe dédié.

## Collaboration entre le Vault et un projet

Le Vault fournit la méthode et les mécanismes transversaux. Le projet possède son contexte local. Une amélioration découverte dans un projet ne remonte dans le Vault que si elle est réellement généralisable et validée par un human gate.

Le Vault ne remplace jamais le contexte local d’un projet et n’importe jamais automatiquement sa connaissance métier.

## Cycle de contexte

`work → capture/proposal/decision selon le besoin → current state → handoff si nécessaire → reprise`

Une capture conserve une connaissance durable. Une proposal garde une option importante jusqu'à son arbitrage sans se présenter comme une décision. Une décision enregistre un choix explicitement validé. Le fichier `current-state.md`, maintenu dans le projet concerné, fournit une photographie courte et actualisée. Un handoff daté n’est créé que lorsqu’une autre session ou un autre agent doit reprendre le travail de façon fiable.

Le cycle est sélectif : chaque session ne produit pas automatiquement tous les artefacts. Voir la [règle du cycle de contexte V2](./rules/RULES-2026-08-17-111018-context-lifecycle-v2.md) et les [modèles réutilisables](./templates/).

## Vérification et preuves

Le Vault distingue l'état réel, le changement, la validation, le snapshot local et la frontière externe. Les mesures techniques sont recalculées au moment utile ; leur simple présence dans un document ne prouve pas qu'un contrôle fonctionne. Voir [Vérification et preuves](./knowledge/verification-and-evidence.md).

## Graphify

Graphify peut aider un agent à retrouver et relier ce qui a été écrit. Il ne remplace ni les fichiers, ni les décisions explicites, ni la discipline documentaire. Les sorties dans `graphify-out/` sont générées et ne doivent jamais être éditées manuellement.

## Points d’entrée

- [Architecture du Vault](./decisions/DECISION-2026-08-17-003000-vault-central-architecture.md)
- [Architecture d'information V1](./decisions/DECISION-2026-08-17-111018-vault-v1-information-architecture.md)
- [Architecture Graphify V1](./decisions/DECISION-2026-08-18-004740-graphify-v1-architecture.md)
- [Modèle opératoire du Vault](./knowledge/BRIEF-2026-08-17-003000-vault-concept-operating-model.md)
- [Modèle opératoire des projets V2](./knowledge/BRIEF-2026-08-17-211522-project-operating-model-v2.md)
- [Vérification et preuves](./knowledge/verification-and-evidence.md)
- [Règles de conduite](./rules/RULES-2026-08-17-005717-vault-operating-rules.md)
- [Cycle de contexte V2](./rules/RULES-2026-08-17-111018-context-lifecycle-v2.md)
