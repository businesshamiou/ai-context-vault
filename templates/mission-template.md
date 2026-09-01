---
type: mission
mission_id: "NNN"            # identité permanente de la lignée, chaîne entre guillemets (ex. "018")
correction:                  # "Cxx" si correction, alors `supersedes:` (ligne suivante) porte le chemin du fichier remplacé ; sinon omettre les deux clés entièrement (pas de valeur vide)
supersedes:
status: AUTHORIZED           # autorisation à la création — figé, jamais retouché ensuite
title: "<titre de la Mission>"
description: "<une à deux phrases>"  # écrites par l'auteur au moment du dépôt, jamais générées par un modèle tiers (232341 §2.1)
created_at: "YYYY-MM-DDTHH:MM:SS±HH:MM"
timezone: America/Montreal
scope: <slug-kebab-case>
artifact_state: GENERATED_IN_CHAT
---

# MISSION <NNN> — <TITRE>

Rappel : `status` ci-dessus fige l'autorisation à la création de ce fichier ; il n'est jamais retouché. L'état d'exécution de cette Mission vit exclusivement dans `<projet>/missions/MISSION-INDEX.md`, colonne « Statut ».

## Contexte

<!-- Obligatoire (DECISION-2026-09-01-115547 point 1). Dans cet ordre : les faits mesurés qui motivent la Mission, chacun daté et qualifié MESURÉ / DECLARED / HYPOTHÈSE ; ce que l'Executor va trouver sur disque et pourquoi c'est là ; les pièges connus (précédents, défauts d'outil, emplacements trompeurs) ; pourquoi la décision qui autorise cette Mission est ce qu'elle est. -->

<Faits mesurés, état attendu sur disque, pièges, raison de la décision.>

## Objectif

<Résultat poursuivi et raison de l'ouverture de cette Mission.>

## Périmètre

<Dépôts, dossiers ou systèmes concernés.>

Hors périmètre : <ce qui est explicitement exclu.>

## Préconditions

<!-- Ce que l'Executor mesure avant d'écrire quoi que ce soit ; au moindre écart non trivial : STOP et rapport, aucune écriture (232341, Impact). -->

1. <État attendu, mesuré avant toute écriture ; écart non trivial = STOP.>

## Sources

- <Autre source : rapport, Decision, mesure antérieure.>

## Décisions applicables

- <Decision ou contrainte transverse qui s'applique à cette Mission.>

## Contraintes

- <Limite à respecter pendant l'exécution.>

## Étapes

<!-- Aucune étape « supprimer » : soit « déplacer vers _trash/ » (étape agent, empreinte + absence remesurée en validation), soit « suppression par l'Owner » en human gate hors des étapes, mesurée à la reprise (DECISION-2026-08-29-110852). -->
1. <Étape ordonnée.>

## Gates

- Autorisation Owner : <accordée pour ... | en attente>
- Human gate non accordé : <ce qui reste hors autorisation>
- Conditions d'arrêt : <signal qui interrompt la Mission>

## Validations

<!-- Relecture croisée faite par le Pilot avant dépôt (DECISION-2026-09-01-115547 point 2) : chaque critère ci-dessous est atteignable sans violer un interdit de Gates ou de Contraintes ; chaque étape est permise par les mêmes interdits. -->
<!-- Chaque critère porte un compte relatif chiffré, avant et après (232341, Impact) : pas "corrigé", mais "3 avant, 0 après". -->

- <Critère vérifiable qui confirme le résultat, avec son compte avant/après chiffré.>

## Contrat de sortie

<Forme du rapport de clôture attendu : distinction VERIFIED/ANOMALY, preuves, SHA des commits, remesure finale, arrêt explicite.>

## Contrat de reprise

<!-- Rempli seulement si la fenêtre s'arrête en PARTIEL : dernier commit sain, ce qui reste à faire, comment la prochaine fenêtre reprend sans rejouer ce qui est fait (232341, Impact). -->

<Dernier commit sain ; étapes restantes ; point de reprise pour la prochaine fenêtre.>

## Portes

<!-- Une ligne par porte que cette Mission ouvre ou ferme, avec sa ligne CLOSE: exacte si elle se ferme ici (Decision 110935, 232341 Impact). -->

- <clé de porte> — <CLOSE: ... | reste ouverte, raison>

## Liens

- `prescribed by` — [Versionnement des Missions et outputs générés](../rules/RULES-2026-08-17-211522-mission-versioning-and-generated-output.md)
- `amended by` — [Décision — La suppression définitive est un geste Owner](../decisions/DECISION-2026-08-29-110852-deletion-is-owner-gesture-trash-zone.md)
- `amended by` — [Décision — Cohérence interne des Missions](../../workshop-build/workshop-production/decisions/DECISION-2026-09-01-115547-mission-context-coherence-and-least-powerful-reading.md) (hors Vault)
- (à compléter : type — titre — chemin relatif, voir le standard de liens)
