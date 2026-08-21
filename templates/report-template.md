---
type: report
title: "Rapport d'exécution — Mission <NNN>"
created_at: "YYYY-MM-DDTHH:MM:SS±HH:MM"
timezone: America/Montreal
mission_id: "<NNN>"
role: executor
related_mission: "<chemin relatif vers la Mission>"
related_prompt: "<chemin relatif vers le Prompt>"
status: FINAL
---

# RAPPORT D'EXÉCUTION — MISSION <NNN>

## 1. Gates

- Push : <fait | non fait>, dans <quel dépôt>.
- <Autre gate mesuré : version système, appel modèle, garde-fou touché ou non.>

## 2. Fichiers créés et modifiés

**Vault :**
- <Créé | Modifié> : `<chemin relatif>`

**workshop-build :**
- <Créé | Modifié> : `<chemin relatif>`

## 3. Commits

- Vault : `<SHA>` — "<message>"
- workshop-build : `<SHA>` — "<message>"

## 4. Impact sur l'installation

<Changement système, environnement, runbook, ou « Aucun changement ».>

## 5. État final mesuré

<Mesure directe, commande à l'appui, distinguée VERIFIED / DECLARED selon les niveaux de preuve.>

## 6. Écarts

- <Écart avec le Prompt, ou « Aucun écart ».>

## 7. Remesure finale, arrêt

```
<commande de remesure et résultat>
```

Arrêt de la Mission ici.

## Liens

- `prescrit par` — [Canal de rapport d'exécution](../decisions/DECISION-2026-08-21-000236-execution-report-channel.md)
- `source` — [<Mission>](<chemin relatif>), [<Prompt>](<chemin relatif>)
