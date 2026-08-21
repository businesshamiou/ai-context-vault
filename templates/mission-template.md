---
type: mission
mission_id: "NNN"            # identité permanente de la lignée, chaîne entre guillemets (ex. "018")
correction:                  # "Cxx" si correction ; sinon omettre entièrement cette clé (pas de valeur vide)
supersedes:                  # chemin du fichier remplacé si correction ; sinon omettre entièrement cette clé
status: AUTHORIZED           # autorisation à la création — figé, jamais retouché ensuite
title: "<titre de la Mission>"
created_at: "YYYY-MM-DDTHH:MM:SS±HH:MM"
timezone: America/Montreal
scope: <slug-kebab-case>
artifact_state: GENERATED_IN_CHAT
---

# MISSION <NNN> — <TITRE>

Rappel : `status` ci-dessus fige l'autorisation à la création de ce fichier ; il n'est jamais retouché. L'état d'exécution de cette Mission vit exclusivement dans `missions/MISSION-INDEX.md`, colonne « Statut ».

## Objectif

<Résultat poursuivi et raison de l'ouverture de cette Mission.>

## Périmètre

<Dépôts, dossiers ou systèmes concernés.>

Hors périmètre : <ce qui est explicitement exclu.>

## Sources

- Prompt aligné : `<chemin relatif vers le PROMPT correspondant>`
- <Autre source : rapport, Decision, mesure antérieure.>

## Décisions applicables

- <Decision ou contrainte transverse qui s'applique à cette Mission.>

## Contraintes

- <Limite à respecter pendant l'exécution.>

## Étapes

1. <Étape ordonnée.>

## Gates

- Autorisation Owner : <accordée pour ... | en attente>
- Human gate non accordé : <ce qui reste hors autorisation>
- Conditions d'arrêt : <signal qui interrompt la Mission>

## Validations

- <Critère vérifiable qui confirme le résultat.>

## Contrat de sortie

<Forme du rapport de clôture attendu : distinction VERIFIED/ANOMALY, preuves, SHA des commits, remesure finale, arrêt explicite.>

## Liens

- `prescrit par` — [Versionnement des Missions et outputs générés](../rules/RULES-2026-08-17-211522-mission-versioning-and-generated-output.md)
- `<type>` — [<titre>](<chemin relatif>)
