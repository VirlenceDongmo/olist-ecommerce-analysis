# Analyse d'un e-commerce brésilien (Olist)

Analyse de bout en bout de ~100 000 commandes : nettoyage, statistiques, SQL et tableau de bord.

## Question métier
> Comment augmenter le chiffre d'affaires et réduire les retards de livraison ?

Sous-questions :
1. Comment évoluent les ventes dans le temps, par catégorie et par État ?
2. Quels facteurs expliquent le montant d'une commande ?
3. Les retards de livraison dégradent-ils les notes clients ?
4. Quelles actions prioriser, avec quel impact chiffré ?

## Données
Jeu de données public **Brazilian E-Commerce Public Dataset by Olist** (Kaggle).
Instructions de téléchargement et description des tables : [`data/README.md`](data/README.md).

## Outils
Excel (nettoyage, tableaux croisés dynamiques, statistiques) · SQL (SQLite) · Power BI Desktop · Git

## Structure du dépôt
```
olist-ecommerce-analysis/
├── data/
│   ├── raw/          # CSV Olist d'origine (non versionnés)
│   └── processed/    # base SQLite et données nettoyées (non versionnées)
├── sql/              # schéma et requêtes d'analyse
├── excel/            # classeurs d'analyse
├── powerbi/          # fichier .pbix du tableau de bord
├── scripts/          # utilitaires (chargement des CSV dans SQLite)
├── docs/             # méthodologie, journal de nettoyage, conclusions
├── reports/figures/  # graphiques et captures exportés
└── README.md
```

## Avancement
- [x] Structure du projet et dépôt Git
- [ ] Téléchargement et exploration des données
- [ ] Nettoyage (journal dans `docs/journal_nettoyage.md`)
- [ ] Analyse descriptive
- [ ] Analyse statistique (régression, test d'hypothèse)
- [ ] Requêtes SQL
- [ ] Tableau de bord Power BI
- [ ] Recommandations et synthèse

## Résultats
_À compléter à la fin du projet : chiffres clés, captures, recommandations._

## Reproduire le projet
1. Télécharger les données (voir `data/README.md`) dans `data/raw/`.
2. Charger dans SQLite : `python scripts/load_to_sqlite.py`
3. Exécuter les requêtes de `sql/` puis ouvrir les classeurs et le fichier Power BI.

## Licence
Code et documents : MIT (voir `LICENSE`). Les données Olist restent soumises à leur licence d'origine (CC BY-NC-SA 4.0) et ne sont pas redistribuées ici.
