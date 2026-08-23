---
type: marker
title: "{{VAULT_NAME}} — marqueur de racine de travail"
description: "Marqueur remonté : identifie la racine de travail et localise le Vault depuis n'importe quel dossier de projet."
status: active
generated_by: tools/write-marker.sh
---

# {{VAULT_NAME}}

Marqueur de racine de travail. Un fichier posé ici permet à tout dossier de
projet de retrouver le Vault en remontant les dossiers parents jusqu'à le
trouver — même principe que la détection d'un dépôt Git par son dossier
`.git`. [arbitrage : Decision sept arbitrages du 2026-08-23, §1]

## Contrat de rôle

- **Ce qu'il contient** : le transversal — règles, décisions, gabarits, connaissances durables, outillage commun à tous les projets frères.
- **Ce qu'il ne fait pas** : il ne porte aucune personnalité (voix, ton, manière de répondre) ; il ne stocke aucun secret, clé ou credential ; il ne remplace pas le contexte propre à chaque projet.
- **Comment on l'interroge** : par lecture directe des fichiers liés (chemin cité, jamais une affirmation sans source) ; par `tools/find-in-vault.sh` pour la recherche par contenu ; par la fiche d'état du projet en cours (`state/STATE.md`).
- **Comment on l'alimente** : uniquement par Mission exécutée dans le Vault ; toute décision structurante passe par une Decision gravée dans `decisions/`, jamais par écriture directe hors Mission.

## Localisation

Chemin relatif du Vault depuis cette racine de travail : `{{VAULT_RELATIVE_PATH}}`

---

Généré automatiquement par `tools/write-marker.sh` à partir de ce gabarit. Ne pas éditer `VAULT-ROOT.md` à la main : régénérer.

## Liens

- `prescrit par` — [Sept arbitrages de session du 2026-08-23](../decisions/DECISION-2026-08-23-124848-seven-arbitrations-2026-08-23.md)
