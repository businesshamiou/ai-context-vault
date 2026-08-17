# Instructions pour les agents

- Les fichiers du Vault sont la source de vérité. Lire les sources liées avant toute modification.
- Rédiger la prose en français. Utiliser un anglais idiomatique pour les identifiants machine, slugs, clés et noms de dossiers.
- Enregistrer explicitement toute décision structurante. Ne jamais transformer silencieusement une proposition en décision.
- Ne jamais écrire de secret, clé, token, mot de passe ou credential dans le Vault ou dans Git.
- Inspecter chaque fichier avant staging, stage fichier par fichier, puis inspecter le diff staged.
- Ne jamais push automatiquement. Exiger un human gate pour tout push, suppression importante, renommage structurant, partage sensible ou autre action sensible.
- Ne jamais éditer manuellement `graphify-out/`.
- Maintenir la frontière entre le Vault et les projets externes : le Vault contient le transversal ; chaque projet conserve son contexte local.
- Ne jamais importer automatiquement dans le Vault le contexte métier, les décisions ou les artefacts propres à un projet.
- Toute amélioration transversale issue d’un projet doit être validée avant son intégration au Vault.
- Ne pas introduire dans le Vault les prompts, présentations, storyboards, supports ou outils dont le seul rôle est de fabriquer le workshop.
