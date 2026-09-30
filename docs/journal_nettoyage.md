# Journal de nettoyage

Consigner chaque décision : ce qui a été constaté, ce qui a été fait, combien de lignes sont concernées.

| Date | Table | Problème constaté | Décision | Lignes touchées |
|---|---|---|---|---|
| 2026-09-29 | customers | `customer_id` est recréé à chaque commande : 99 441 valeurs distinctes contre 96 096 `customer_unique_id` | Identifier un client par `customer_unique_id` pour tout comptage de clients ou d'analyse de fidélité | ~3 345 commandes issues de clients déjà connus |
| 2026-09-29 | orders | Dates stockées en texte (`AAAA-MM-JJ hh:mm:ss`) : le tri alphabétique équivaut au tri chronologique, donc `MIN`/`MAX` fonctionnent directement | Conserver le format ; utiliser `strftime` ou `substr` pour extraire année et mois | toutes |
| 2026-09-29 | orders | Période couverte : du 2016-09-04 au 2018-10-17 | Volumes par mois vérifiés (voir lignes du 2026-09-30) ; périmètre d'analyse retenu : 2017-01 à 2018-08 | voir ci-dessous |
| 2026-09-29 | orders | 2 963 commandes sur 99 441 n'ont pas le statut `delivered` (2,98 %) | Exclure ces commandes de l'analyse des retards de livraison ; les conserver pour l'analyse du chiffre d'affaires selon la définition retenue | 2 963 |
| 2026-09-29 | orders / customers | Ventes très concentrées : SP = 41 746 commandes (~42 %), les 10 premiers États ~90 % | À reprendre dans l'analyse par État et dans les recommandations | — |
| 2026-09-29 | order_items | Une ligne = un article, pas une commande : joindre `orders` à `order_items` produit une ligne par article, donc des commandes répétées | Compter les commandes avec `COUNT(DISTINCT order_id)` ; obtenir un montant par commande en regroupant par `order_id` ou en agrégeant `order_items` avant la jointure | `nb_lignes` = 112 650 ; `nb_commandes` = 98 666 (soit ~1,14 article par commande, 13 984 lignes supplémentaires) |
| 2026-09-29 | orders / order_items | 775 commandes n'ont aucun article (99 441 − 98 666), presque toutes `unavailable` (78 %) ou `canceled` (21 %) : logique, un produit indisponible ou annulé n'est jamais expédié. Anomalies à examiner : 1 commande `shipped`, 2 `invoiced` et 5 `created` sans article | Utiliser `LEFT JOIN` pour conserver toutes les commandes dans la table d'analyse ; `JOIN` simple les ferait disparaître | 775 commandes sans article : unavailable 603, canceled 164, created 5, invoiced 2, shipped 1 |
| 2026-09-29 | order_items | La colonne `order_item_quantity` n'existe pas : `order_item_id` est le numéro de l'article dans la commande (1, 2, 3...), pas une quantité | Montant d'une commande = `SUM(price)` ; frais de port = `SUM(freight_value)` ; nombre d'articles = `COUNT(*)` | — |
| 2026-09-30 | table d'analyse | Construction du montant par commande : agrégation de `order_items` par `order_id` dans une sous-requête (`nb_articles`, `montant`, `frais_port`), puis `LEFT JOIN` depuis `orders` | Une ligne par commande, sans doublon ; les 99 441 commandes sont conservées. Contrôle : somme des montants = 13 591 643,70 dans la table d'analyse et dans `order_items` (identiques) | 99 441 (contrôlé) |
| 2026-09-30 | table d'analyse | Les 775 commandes sans article n'ont ni montant ni frais de port | Conserver `NULL` plutôt que 0 : `AVG` et `SUM` ignorent les valeurs vides, donc le panier moyen n'est pas tiré vers le bas par des commandes qui n'ont jamais eu d'article ; `COALESCE(montant, 0)` reste possible au cas par cas | 775 (contrôlé) |
| 2026-09-30 | table d'analyse | Chiffre d'affaires total des articles (hors frais de port) : 13 591 643,70 ; panier moyen ≈ 137,75 sur les 98 666 commandes avec articles | Utiliser `price` seul comme « montant » ; les frais de port restent une colonne distincte | — |
| 2026-09-30 | table d'analyse | Ajout de `mois_achat` = `strftime('%Y-%m', order_purchase_timestamp)` | Format `AAAA-MM`, qui se trie dans l'ordre chronologique ; 0 date vide | 99 441 (contrôlé) |
| 2026-09-30 | orders | Volumes mensuels : 25 mois distincts (novembre 2016 absent) ; 2016 = 329 commandes sur 3 mois seulement ; 2017-01 = 800 puis croissance jusqu'au pic de 7 544 en 2017-11 (probable Black Friday, hypothèse à vérifier avec le détail par jour) ; plateau de 6 000 à 7 300 par mois en 2018 ; 2018-09 = 16 et 2018-10 = 4 | Les mois de 2016 (montée en charge) et de septembre-octobre 2018 (effectifs quasi nuls) ne sont pas représentatifs : les exclure des analyses de tendance | 349 |
| 2026-09-30 | orders | Périmètre d'analyse | Retenir **2017-01 à 2018-08 (20 mois)** : 99 092 commandes conservées, 349 exclues (0,35 %) : 329 en 2016 et 20 en 2018-09/10. Contrôle : somme des commandes mensuelles = 99 441 | 349 exclues |
| 2026-09-30 | table d'analyse | Export en CSV (`data/processed/orders_analysis.csv`) : `wc -l` = 99 442 lignes (99 441 commandes + en-tête), colonnes `order_id, order_status, mois_achat, nb_articles, montant, frais_port` | Fichier généré hors dépôt (dossier ignoré par git) ; à régénérer par `sql/05_export.sql` | 99 441 (contrôlé) |
| 2026-09-30 | orders_analysis | Import dans LibreOffice Calc : contrôles réussis : `COUNTA` = 99 441 ; somme de `montant` = 13 591 643,70 (identique à SQL) ; 775 cellules vides | Import validé ; classeur enregistré en `.xlsx` dans `excel/` | 99 441 (contrôlé) |
| 2026-09-30 | ventes_mensuelles | Tableau croisé dynamique sur `mois_achat`, filtré sur les 20 mois du périmètre : 99 092 commandes et 13 541 712,78 de montant ; chiffre d'affaires des mois exclus = 49 930,92 (13 591 643,70 − 13 541 712,78) | Périmètre appliqué par filtre sur `mois_achat` ; totaux cohérents avec la source | 99 092 (contrôlé) |
| 2026-09-30 | ventes_mensuelles | Graphiques créés directement depuis le tableau croisé dynamique : la ligne « Total Result » était tracée comme un 21e point (échelle écrasée), le type était un nuage de points et l'axe affichait 1 à 21 | Copie des 20 mois en valeurs seules dans une plage à part (`mois`, `commandes`, `chiffre_affaires`), puis graphiques en courbes avec étiquettes de mois | — |
| 2026-09-30 | ventes_mensuelles | Résultats : corrélation commandes / chiffre d'affaires ≈ 0,99 ; panier moyen entre 123,7 et 150,4 (135,5 en janvier-août 2017 contre 136,8 en 2018) ; janvier-août 2018 contre 2017 : commandes +135 %, chiffre d'affaires +137 % ; plateau en 2018 (6 167 à 7 269 commandes par mois) ; pic en 2017-11 (7 544 commandes, 1,01 M) puis −25 % en décembre | La croissance vient du volume et non du panier ; l'activité se stabilise en 2018. Hypothèse Black Friday non vérifiée | — |

## Import de la table d'analyse dans LibreOffice Calc

**1. Exporter depuis SQLite**

`sql/05_export.sql` contient uniquement le `SELECT` final de la table d'analyse (sans les requêtes de contrôle, qui pollueraient le CSV). Dans le shell SQLite :

```
.headers on
.mode csv
.output data/processed/orders_analysis.csv
.read sql/05_export.sql
.output stdout
.mode column
```

- `.headers on` écrit les noms de colonnes en première ligne.
- `.mode csv` sépare les valeurs par des virgules.
- `.output fichier` redirige le résultat vers le fichier au lieu de l'écran ; `.output stdout` rétablit l'affichage normal.

**2. Contrôler le fichier**

`wc -l data/processed/orders_analysis.csv` doit afficher 99 442 (99 441 commandes plus la ligne d'en-tête). `head -3` montre les premières lignes pour vérifier l'ordre des colonnes.

**3. Ouvrir dans Calc (Fichier > Ouvrir)**

Dans la boîte d'importation :

| Réglage | Valeur | Pourquoi |
|---|---|---|
| Jeu de caractères | UTF-8 | évite les caractères abîmés |
| Séparateur | virgule | c'est celui du CSV exporté |
| Langue des colonnes numériques | Anglais (USA) | la locale française attend une virgule décimale ; sans ce réglage `72.0` est lu comme du texte |
| Type de `mois_achat` | Texte | sinon `2017-03` devient une date et le regroupement par mois est perdu |
| Type de `order_id` | Texte | ces identifiants hexadécimaux pourraient être lus comme des nombres en notation scientifique |

**4. Enregistrer en `.xlsx`**

Enregistrer aussitôt dans `excel/analyse_olist.xlsx` (Enregistrer sous, format Excel 2007-365).

**5. Contrôler l'import**

| Contrôle | Formule (colonne E = `montant`) | Attendu | Obtenu |
|---|---|---|---|
| Nombre de commandes | `=COUNTA(A2:A99442)` (`NBVAL` en interface française) | 99 441 | 99 441 |
| Somme des montants | `=SUM(E2:E99442)` (`SOMME`) | 13 591 643,70 | 13 591 643,7 |
| Montants vides | `=COUNTBLANK(E2:E99442)` (`NB.VIDE`) | 775 | 775 |

Le résultat de la somme s'affiche avec une virgule (`13591643,7`) car Calc est en locale française : c'est la même valeur que côté SQL.

## Enseignements techniques

- **Division entière en SQLite :** diviser deux entiers renvoie un entier tronqué. `100 * 2963 / 99441` donnait 2, alors que le résultat exact est 2,98. Solution : utiliser `100.0` (au moins un nombre décimal dans le calcul).
- **Contrôler chaque résultat par un calcul indépendant :** un résultat plausible peut être faux. La vérification `total` et `non_livrees` a permis de repérer l'erreur ci-dessus.
- **Une seule syntaxe de jointure :** écrire `FROM a JOIN b ON ...`. Mélanger `FROM a, b` (virgule) et `JOIN`, surtout avec deux fois le même alias, produit l'erreur `ambiguous column name`.
- **Vérifier les noms de colonnes** avant d'écrire une requête (`.schema order_items` dans le shell, ou `sql/00_schema.sql`). Une colonne supposée mais inexistante bloque la requête.
- **Grain d'une table :** avant toute jointure, se demander « une ligne = quoi ? » (article, commande, client). Joindre deux tables de grains différents multiplie les lignes.
- **`JOIN` contre `LEFT JOIN` :** `JOIN` ne garde que les lignes qui ont une correspondance des deux côtés ; `LEFT JOIN` garde toutes les lignes de la table de gauche. `WHERE table_droite.cle IS NULL` isole les lignes sans correspondance.
- **Agréger avant de joindre :** pour obtenir un total par commande, calculer les sommes dans une sous-requête regroupée par `order_id`, puis la joindre à `orders`. La sous-requête doit avoir un alias.
- **`NULL` n'est pas 0 :** une valeur vide signifie « pas de donnée », et 0 signifie « valeur nulle ». Les fonctions d'agrégation ignorent `NULL`, ce qui protège les moyennes.
- **Trois contrôles après chaque construction de table :** nombre de lignes attendu, somme comparée à la table source, nombre de valeurs vides attendu.
- **`strftime('%Y-%m', date)` :** extrait année et mois d'une date en texte ; le format `AAAA-MM` se trie chronologiquement. `GROUP BY` accepte l'alias de la colonne.
- **Repérer les mois incomplets avant un graphique de tendance :** un mois de fin de période à 16 commandes ne traduit pas une chute des ventes mais l'arrêt des données. Toujours regarder les volumes mensuels avant de tracer une courbe.
- **Compter les mois calendaires :** de 2016-09 à 2018-10 il y a 26 mois ; en trouver 25 signale un mois absent (ici novembre 2016).
- **Séparer requête d'export et requêtes de contrôle :** un `.read` exécute tout le fichier ; le CSV ne doit contenir que la requête finale.
- **Locale et import CSV :** avec une locale française, régler la langue des colonnes numériques sur Anglais (USA), sinon les décimales à point sont lues comme du texte. Toujours contrôler après import : nombre de lignes, somme, valeurs vides.
- **Forcer le type Texte** pour les identifiants et les périodes (`order_id`, `mois_achat`) : Calc convertit sinon `2017-03` en date.
- **Graphique et tableau croisé dynamique :** un graphique construit sur le tableau reprend la ligne de total. Copier les valeurs des lignes utiles dans une plage à part avant de tracer. Courbe pour une évolution dans le temps, nuage de points pour lier deux variables numériques.
- **Noms de fonctions Calc :** ils suivent la langue de l'interface (anglaise ici : `COUNTA`, `SUM`, `COUNTBLANK`, `CORREL`). L'erreur `#NAME?` signale un nom de fonction non reconnu ; le séparateur d'arguments dépend de la locale (`;` en locale française).
- **Arrondi d'affichage :** les valeurs comme `247303,019999996` sont du bruit de calcul ; les formater à 2 décimales sans modifier les données.
- **Corrélation et lien arithmétique :** chiffre d'affaires = commandes × panier moyen ; une corrélation de 0,99 entre commandes et chiffre d'affaires est attendue et ne constitue pas une découverte. L'information utile est la stabilité du panier moyen.
- **Comparer les mêmes mois d'une année sur l'autre** (ici janvier à août) pour neutraliser la saisonnalité.
- **Les décisions de périmètre se consignent ici :** chaque exclusion de lignes doit figurer avec son motif et son effectif.

## À traiter

- Ajouter à la table d'analyse : délai de livraison et indicateur de retard (`julianday`), État du client, note moyenne de l'avis.
- Organiser le classeur `excel/analyse_olist.xlsx` (onglets `lisez_moi`, `controles`, `donnees`, puis un onglet par analyse).
- Réaliser l'analyse de la distribution du montant dans Calc (statistiques descriptives, histogramme, boîte à moustaches ; 775 cellules vides à gérer).
- Corriger la formule de corrélation de `ventes_mensuelles` (`=CORREL(...)`) et formater le panier moyen à 2 décimales.
- Vérifier l'hypothèse Black Friday : commandes par jour en novembre 2017.
- Appliquer le périmètre 2017-01 à 2018-08 (filtre sur `mois_achat`) dans les analyses de tendance.
- Examiner les 8 commandes sans article dont le statut n'est ni `unavailable` ni `canceled` (1 `shipped`, 2 `invoiced`, 5 `created`) : erreur de saisie ou commandes en cours ?
- Contrôler les commandes `delivered` sans date de livraison (`sql/01_controle_qualite.sql`).
- Examiner les commandes avec plusieurs avis avant toute jointure avec `order_reviews`.
