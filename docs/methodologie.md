# Méthodologie

## Question métier
Voir le README.

## Périmètre
- Commandes retenues : à définir (par exemple statut `delivered` pour l'analyse des livraisons).
- Période : à définir après exploration.

## Définition des indicateurs
| Indicateur | Définition |
|---|---|
| Chiffre d'affaires | somme de `price` (hors frais de port) — à confirmer |
| Panier moyen | chiffre d'affaires / nombre de commandes |
| Retard de livraison | `order_delivered_customer_date` > `order_estimated_delivery_date` |
| Délai de livraison | jours entre achat et livraison |

## Étapes
1. Exploration et contrôle qualité
2. Nettoyage
3. Analyse descriptive
4. Analyse statistique
5. Requêtes SQL
6. Tableau de bord
7. Recommandations

## Décisions et hypothèses
_À compléter au fil du projet._
