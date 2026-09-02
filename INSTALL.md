---
title: "Installer le Vault"
description: "Page d'entrée du paquet distribué : décompresser, ouvrir Claude Code dans le dossier, lancer /first-install, ce qui reste un geste humain."
status: active
---

# INSTALLER LE VAULT

Ce paquet contient le Vault : une mémoire durable et un système opératoire transversal pour travailler avec l'IA. Trois gestes suffisent pour commencer.

## 1. Décompresser

Décompressez l'archive dans un dossier de travail, à côté (jamais à l'intérieur) de vos autres projets. Le dossier `vault/` qui en résulte est la racine à ne jamais renommer.

## 2. Ouvrir Claude Code dans le dossier

Ouvrez une session Claude Code avec ce dossier `vault/` comme répertoire de travail.

## 3. Lancer `/first-install`

Ce skill mesure ce qui manque sur ce poste et installe le nécessaire — jonctions des skills, épingle des gardiens, fichiers de repérage — sans jamais rien écraser. Il est rejouable : une seconde exécution confirme simplement que tout est en place.

`/first-install` propose aussi la liste des skills à importer manuellement dans claude.ai : cet import reste un geste humain, jamais automatisé.

## Licence

Le Vault, y compris les skills fabriqués par ce projet et la bibliothèque de skills adoptée, est distribué sous licence MIT. Voir [LICENSE](./LICENSE) ; un fichier LICENSES, à la racine de chaque paquet construit, détaille la licence de chaque composant.

## Liens

- `see also` — [Skill first-install](./skills/first-install/SKILL.md)
- `see also` — [Licence MIT du Vault](./LICENSE)
