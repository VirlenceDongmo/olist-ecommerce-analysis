# Méthodologie

## Question métier
Voir le README. En bref : comment augmenter le chiffre d'affaires et réduire les retards de livraison ? Quatre sous-questions : évolution des ventes par catégorie et par ville ; facteurs qui expliquent le montant d'une commande ; effet des retards sur les notes clients ; actions à prioriser avec un impact chiffré.

## Périmètre
- Période : 2017-01 à 2018-08 (20 mois), 99 092 commandes. 349 commandes exclues (0,35 %) : 329 en 2016 (montée en charge) et 20 en 2018-09 et 2018-10 (effectifs quasi nuls). Le détail est dans `journal_nettoyage.md`.
- Chiffre d'affaires et montants : commandes du périmètre qui ont un montant (98 353), quel que soit le statut. Les commandes annulées ou indisponibles qui ont un montant restent comptées.
- 739 commandes du périmètre n'ont ni article ni montant : comptées dans le nombre de commandes, ignorées dans les calculs de montant.
- Retards et notes : commandes avec date de livraison réelle (96 204), dont 95 561 avec une note. Les 2 769 avis sur des commandes sans date de livraison réelle sont exclus.
- Unité : montants en R$ (réal brésilien), hors frais de port.

## Définition des indicateurs
| Indicateur | Définition |
|---|---|
| Chiffre d'affaires | somme de `price` (hors frais de port), confirmé ; 13 541 712,78 R$ sur le périmètre |
| Montant d'une commande | `SUM(price)` ; frais de port = `SUM(freight_value)` ; nombre d'articles = `COUNT(*)` |
| Panier moyen | chiffre d'affaires / nombre de commandes. `ventes_mensuelles` divise par toutes les commandes du mois (dont celles sans montant) ; sur les 98 353 commandes avec montant, il vaut 137,68 R$ |
| Retard de livraison | `retard_jours` > 0, avec `retard_jours` = date de livraison réelle − date estimée, en jours calendaires |
| Part de commandes en retard | commandes en retard / commandes avec date de livraison réelle et note |
| Délai de livraison | jours entre achat et livraison : pas encore calculé |
| Note client | note de 1 à 5 de l'avis le plus récent de la commande |
| Catégorie | catégorie de l'article le plus cher de la commande |
| Croissance | chiffre d'affaires de janvier-août 2018 / chiffre d'affaires de janvier-août 2017 − 1 |
| Client | `customer_unique_id` (et non `customer_id`, recréé à chaque commande) ; absent du classeur à ce stade |

## Étapes
| Étape | Statut | Livrable |
|---|---|---|
| 1. Exploration et contrôle qualité | Fait | `journal_nettoyage.md` |
| 2. Nettoyage | Fait | table d'analyse, périmètre appliqué |
| 3. Analyse descriptive | Fait | onglets `ventes_mensuelles`, `categories_villes`, `distribution_montant` |
| 4. Analyse statistique | Fait | onglets `retards` (test de Welch, corrélations) et `regression` |
| 5. Requêtes SQL | Partiel | construction et export de la table d'analyse (`sql/05_export.sql`) ; requêtes des analyses du classeur à documenter |
| 6. Tableau de bord | À faire | |
| 7. Recommandations | Première version | onglet `synthese` : quatre actions chiffrées par scénarios, à compléter avec `customer_unique_id` |

## Décisions et hypothèses
Décisions (chacune est consignée avec ses effectifs dans `journal_nettoyage.md`) :
- Un client = `customer_unique_id`.
- Une commande = une ligne dans la table d'analyse ; le montant est calculé en agrégeant `order_items` avant la jointure, avec un `LEFT JOIN` depuis `orders`.
- `NULL` plutôt que 0 pour les commandes sans article, afin de ne pas tirer les moyennes vers le bas.
- Périmètre 2017-01 à 2018-08, retiré de `donnees`.
- Analyse des retards sur les commandes avec date de livraison réelle, pas sur le seul statut `delivered`.
- Montant analysé en logarithme dans la régression (distribution asymétrique) ; effet lu en pourcentage approximatif.
- Croissance mesurée sur janvier-août, seuls mois comparables entre 2017 et 2018.

Hypothèses :
- Le pic de commandes de 2017-11 vient de la Black Friday : non vérifié (commandes par jour à examiner).
- Scénarios de `synthese`, purement illustratifs et modifiables : 50 % des retards supprimés, +2 points de commandes à plusieurs articles, 50 % de l'écart de volume récupéré, 25 % du chiffre d'affaires annulé récupéré. Résultats : environ 1 700 notes 1 ou 2 évitées sur 20 mois pour les retards, environ +1,1 % de chiffre d'affaires pour le panier multi-articles.

Limites :
- Le lien entre retards et notes est une association, pas une preuve de causalité.
- L'impact des retards est chiffré en notes et non en chiffre d'affaires : le classeur n'a ni les rachats ni `customer_unique_id`.
- La régression explique peu (R² = 0,159) ; la catégorie seule explique 13 % de la variation, le modèle complet avec catégorie environ 26 % (calculé hors classeur).
- Les analyses par catégorie et par ville sont descriptives, limitées aux 8 premières ; les commandes sans catégorie sont dans « Autres ».
- Les données s'arrêtent en août 2018 : pas de recul au-delà.
