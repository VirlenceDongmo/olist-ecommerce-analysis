# Journal de nettoyage

Consigner chaque décision : ce qui a été constaté, ce qui a été fait, combien de lignes sont concernées.

| Date | Table | Problème constaté | Décision | Lignes touchées |
|---|---|---|---|---|
| 2026-09-29 | customers | `customer_id` est recréé à chaque commande : 99 441 valeurs distinctes contre 96 096 `customer_unique_id` | Identifier un client par `customer_unique_id` pour tout comptage de clients ou d'analyse de fidélité | ~3 345 commandes issues de clients déjà connus |
| 2026-09-29 | orders | Dates stockées en texte (`AAAA-MM-JJ hh:mm:ss`) : le tri alphabétique équivaut au tri chronologique, donc `MIN`/`MAX` fonctionnent directement | Conserver le format ; utiliser `strftime` ou `substr` pour extraire année et mois | toutes |
| 2026-09-29 | orders | Période couverte : du 2016-09-04 au 2018-10-17 | Volumes par mois à vérifier avant de choisir le périmètre (2016 semble très peu fourni, à confirmer) | à déterminer |
| 2026-09-29 | orders | 2 963 commandes sur 99 441 n'ont pas le statut `delivered` (2,98 %) | Exclure ces commandes de l'analyse des retards de livraison ; les conserver pour l'analyse du chiffre d'affaires selon la définition retenue | 2 963 |
| 2026-09-29 | orders / customers | Ventes très concentrées : SP = 41 746 commandes (~42 %), les 10 premiers États ~90 % | À reprendre dans l'analyse par État et les recommandations | — |
| 2026-09-29 | order_items | Une ligne = un article, et non une commande : joindre `orders` à `order_items` produit une ligne par article, donc des commandes répétées | Pour compter des commandes, utiliser `COUNT(DISTINCT order_id)` ; pour un montant par commande, agréger `order_items` **avant** de joindre ou regrouper par `order_id` | à compléter : `nb_lignes` = ___ , `nb_commandes` = ___ |
| 2026-09-29 | order_items | La colonne `order_item_quantity` n'existe pas : `order_item_id` n'est que le numéro de l'article dans la commande (1, 2, 3...), pas une quantité | Le montant d'une commande = `SUM(price)` ; les frais de port = `SUM(freight_value)` ; le nombre d'articles = `COUNT(*)` | — |

## Enseignements techniques

- **Division entière en SQLite :** diviser deux entiers renvoie un entier tronqué. `100 * 2963 / 99441` donnait 2, alors que le résultat exact est 2,98. Solution : utiliser `100.0` (au moins un nombre décimal dans le calcul).
- **Contrôler chaque résultat par un calcul indépendant** : un résultat plausible peut être faux. Ici, la vérification `total` et `non_livrees` a permis de repérer l'erreur.
- **Une seule syntaxe de jointure :** écrire `FROM a JOIN b ON ...`. Mélanger `FROM a, b` (virgule) et `JOIN` avec le même alias produit l'erreur `ambiguous column name`.
- **Vérifier les noms de colonnes** dans `sql/00_schema.sql` avant d'écrire une requête (`.schema order_items` dans le shell).


