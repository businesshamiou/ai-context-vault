---
type: provenance
title: "Provenance — bibliothèque de skills externes vault/skills/external/"
description: "Note de provenance de la bibliothèque de 30 skills externes adoptés (DECISION-2026-08-28-151235, DECISION-2026-08-30-210726) et rapatriés dans le Vault (DECISION-2026-08-28-160213) : source amont, version figée, licence, dates d'entrée, chaîne d'audits, et l'exception documentée de scroll-film-studio."
created_at: "2026-08-28T16:11:00-04:00"
timezone: America/Montreal
status: active
scope: skills-external-provenance
---

# PROVENANCE — `vault/skills/external/`

Ce dossier est une frontière de provenance (`DECISION-2026-08-28-160213` §2) : il ne contient que du matériel d'auteurs tiers, jamais les skills propres du Vault.

## Source

- **Auteur** : Matt Pocock.
- **Dépôt amont** : `https://github.com/mattpocock/skills`.
- **Paquet** : `mattpocock-skills`, **version figée `1.2.3`** (confirmée par `package.json` de l'archive source ; empreinte de commit `9c9f36ccd3995266cd675468af71639c8dde1ec5`, typique d'un export `codeload.github.com` — mesurée Mission 077 §6).
- **Licence** : MIT, embarquée verbatim à [`LICENSE-mattpocock-skills.txt`](./LICENSE-mattpocock-skills.txt).
- **Archive locale** : `skills-main.zip` (27 des 28 skills) et `Super website skill v2.zip` (`scroll-film-studio`), toutes deux dans `C:\Users\hamio\Workspaces\workshops\dossier_skills\`, non versionnées, hors périmètre de cette bibliothèque.

## Exception — `scroll-film-studio`

Aucune licence, mention d'auteur ou de version amont détectée dans son archive source (`Super website skill v2.zip`) ; seul `scripts/package.json` porte un nom et une version locale (`scroll-film-studio-scripts`, `1.0.0`, `private: true`), sans auteur ni licence (Mission 077, table §274). La licence MIT ci-dessus couvre les 27 autres skills issus de `skills-main` ; elle ne s'étend pas à `scroll-film-studio`, dont le statut de licence reste **non déterminé**.

## Chaîne d'audits

1. [Rapport d'exécution — Mission 077, audit du dossier de skills externe](../../../workshop-build/workshop-production/reports/REPORT-2026-08-27-172150-077-external-skills-audit.md) — premier audit, inventaire des 6 archives, identification du dépôt amont et de l'empreinte de commit, relevé de l'absence de licence sur `scroll-film-studio`.
2. `generated/SKILLS-AUDIT-REPORT-2026-08-27-222450.md` (dépôt `workshop-build`, hors index canonique) — second audit, notation comparative (score, verdict) des 28 skills adoptés et des 8 refusés, base de [DECISION-2026-08-28-151235](../../../workshop-build/workshop-production/decisions/DECISION-2026-08-28-151235-external-skills-adoption-score-threshold.md).

## Dates d'entrée

- **2026-08-28** — installation en portée personnelle (`C:\Users\hamio\.claude\skills\`), 28 dossiers, 94 fichiers (Mission 081).
- **2026-08-28** — entrée dans le Vault (`vault/skills/external/`), même contenu, copie vérifiée avant toute jonction (Mission 082, exécution de `DECISION-2026-08-28-160213`).
- **2026-08-30** — cycle update-ou-rejet (Mission 104, exécution de `DECISION-2026-08-28-171209`) : clone amont mesuré au commit `6654f6b60cd9d5be8b54c6fafe44346dabeb3b76` (`package.json` toujours à la version `1.2.3` — commits amont non versionnés depuis le dernier changeset), 24/27 skills de la case A mis à jour (corps + fichiers compagnons remplacés verbatim), 3/27 déjà identiques (`grill-me`, `grill-with-docs`, `handoff`), **0 CONFLIT, 0 ANOMALIE**. `metadata-upstream-version` reste `"1.2.3"` sur les 27 (valeur mesurée inchangée). `scroll-film-studio` non touché (aucun amont). Détail : `../../../workshop-build/workshop-production/reports/REPORT-2026-08-30-104-external-skills-upstream-update.md` (hors Vault).
- **2026-08-30** — `implement-spec` et `retro` entrent dans le Vault (Mission 105-C01), depuis le même clone amont, même commit `6654f6b60cd9d5be8b54c6fafe44346dabeb3b76`, `metadata-upstream-version` `"1.2.3"` : adoption par arbitrage Owner nominatif, `DECISION-2026-08-30-210726`, non audités. La liste passe de 28 à 30.

## Liens

- `applies` — [Décision — La bibliothèque de skills externes entre dans le Vault](../../../workshop-build/workshop-production/decisions/DECISION-2026-08-28-160213-skills-library-into-vault-amendment.md) (hors Vault)
- `applies` — [Décision — Adoption des skills externes au seuil de score](../../../workshop-build/workshop-production/decisions/DECISION-2026-08-28-151235-external-skills-adoption-score-threshold.md) (hors Vault)
- `source` — [Catalogue des 28 skills externes installés](../../../workshop-build/workshop-production/knowledge-notes/KNOWLEDGE-NOTE-2026-08-28-151755-external-skills-catalog.md) (hors Vault)
