# Journal de nettoyage

Consigner chaque décision : ce qui a été constaté, ce qui a été fait, combien de lignes sont concernées.

| Date | Table | Problème constaté | Décision | Lignes touchées |
|---|---|---|---|---|
| 2026-09-29 | customers | `customer_id` est recréé à chaque commande : 99 441 valeurs distinctes contre 96 096 `customer_unique_id` | Identifier un client par `customer_unique_id` pour tout comptage de clients ou d'analyse de fidélité | ~3 345 commandes issues de clients déjà connus |
| 2026-09-29 | orders | Dates stockées en texte (`AAAA-MM-JJ hh:mm:ss`) : le tri alphabétique équivaut au tri chronologique, donc `MIN`/`MAX` fonctionnent directement | Conserver le format ; utiliser `strftime` ou `substr` pour extraire année et mois | toutes |
| 2026-09-29 | orders | Période couverte : du 2016-09-04 au 2018-10-17 | Volumes par mois à vérifier avant de choisir le périmètre (2016 semble très peu fourni, à confirmer) | à déterminer |
| 2026-09-29 | orders | 2 963 commandes sur 99 441 n'ont pas le statut `delivered` (2,98 %) | Exclure ces commandes de l'analyse des retards de livraison ; les conserver pour l'analyse du chiffre d'affaires selon la définition retenue | 2 963 |
| 2026-09-29 | orders / customers | Ventes très concentrées : SP = 41 746 commandes (~42 %), les 10 premiers États ~90 % | À reprendre dans l'analyse par État et dans les recommandations | — |
| 2026-09-29 | order_items | Une ligne = un article, pas une commande : joindre `orders` à `order_items` produit une ligne par article, donc des commandes répétées | Compter les commandes avec `COUNT(DISTINCT order_id)` ; obtenir un montant par commande en regroupant par `order_id` ou en agrégeant `order_items` avant la jointure | `nb_lignes` = 112 650 ; `nb_commandes` = 98 666 (soit ~1,14 article par commande, 13 984 lignes supplémentaires) |
| 2026-09-29 | orders / order_items | 775 commandes n'ont aucun article (99 441 − 98 666), presque toutes `unavailable` (78 %) ou `canceled` (21 %) : logique, un produit indisponible ou annulé n'est jamais expédié. Anomalies à examiner : 1 commande `shipped`, 2 `invoiced` et 5 `created` sans article | Utiliser `LEFT JOIN` pour conserver toutes les commandes dans la table d'analyse ; `JOIN` simple les ferait disparaître | 775 commandes sans article : unavailable 603, canceled 164, created 5, invoiced 2, shipped 1 |
| 2026-09-29 | order_items | La colonne `order_item_quantity` n'existe pas : `order_item_id` est le numéro de l'article dans la commande (1, 2, 3...), pas une quantité | Montant d'une commande = `SUM(price)` ; frais de port = `SUM(freight_value)` ; nombre d'articles = `COUNT(*)` | — |

## Enseignements techniques

- **Division entière en SQLite :** diviser deux entiers renvoie un entier tronqué. `100 * 2963 / 99441` donnait 2, alors que le résultat exact est 2,98. Solution : utiliser `100.0` (au moins un nombre décimal dans le calcul).
- **Contrôler chaque résultat par un calcul indépendant :** un résultat plausible peut être faux. La vérification `total` et `non_livrees` a permis de repérer l'erreur ci-dessus.
- **Une seule syntaxe de jointure :** écrire `FROM a JOIN b ON ...`. Mélanger `FROM a, b` (virgule) et `JOIN`, surtout avec deux fois le même alias, produit l'erreur `ambiguous column name`.
- **Vérifier les noms de colonnes** avant d'écrire une requête (`.schema order_items` dans le shell, ou `sql/00_schema.sql`). Une colonne supposée mais inexistante bloque la requête.
- **Grain d'une table :** avant toute jointure, se demander « une ligne = quoi ? » (article, commande, client). Joindre deux tables de grains différents multiplie les lignes.
- **`JOIN` contre `LEFT JOIN` :** `JOIN` ne garde que les lignes qui ont une correspondance des deux côtés ; `LEFT JOIN` garde toutes les lignes de la table de gauche. `WHERE table_droite.cle IS NULL` isole les lignes sans correspondance.
- **Les décisions de périmètre se consignent ici :** chaque exclusion de lignes doit figurer avec son motif et son effectif.

## À traiter

- Examiner les 8 commandes sans article dont le statut n'est ni `unavailable` ni `canceled` (1 `shipped`, 2 `invoiced`, 5 `created`) : erreur de saisie ou commandes en cours ?
- Vérifier les volumes de commandes par mois (notamment fin 2016 et fin 2018).
- Contrôler les commandes `delivered` sans date de livraison (`sql/01_controle_qualite.sql`).
- Examiner les commandes avec plusieurs avis avant toute jointure avec `order_reviews`.
