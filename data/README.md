# Données

## Source
Brazilian E-Commerce Public Dataset by Olist, sur Kaggle :
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
Licence : CC BY-NC-SA 4.0. Les fichiers ne sont pas versionnés dans ce dépôt.

## Téléchargement
1. Créer un compte Kaggle (gratuit) et télécharger l'archive du jeu de données.
2. Décompresser les 9 fichiers CSV dans `data/raw/`.

## Fichiers attendus dans `data/raw/`
| Fichier | Contenu | Clé |
|---|---|---|
| `olist_orders_dataset.csv` | commandes, statut, dates | `order_id` |
| `olist_order_items_dataset.csv` | articles par commande, prix, frais de port | `order_id` + `order_item_id` |
| `olist_order_payments_dataset.csv` | paiements | `order_id` + `payment_sequential` |
| `olist_order_reviews_dataset.csv` | avis clients (note 1 à 5) | `review_id` |
| `olist_customers_dataset.csv` | clients | `customer_id` |
| `olist_products_dataset.csv` | produits | `product_id` |
| `olist_sellers_dataset.csv` | vendeurs | `seller_id` |
| `olist_geolocation_dataset.csv` | coordonnées par code postal | `geolocation_zip_code_prefix` |
| `product_category_name_translation.csv` | catégories portugais / anglais | `product_category_name` |

## Relations principales
- `orders.customer_id` → `customers.customer_id`
- `order_items.order_id` → `orders.order_id`
- `order_items.product_id` → `products.product_id`
- `order_items.seller_id` → `sellers.seller_id`
- `order_payments.order_id` et `order_reviews.order_id` → `orders.order_id`
- `products.product_category_name` → `product_category_name_translation`

## Points d'attention (à traiter au nettoyage)
- `customer_id` change à chaque commande : utiliser `customer_unique_id` pour identifier un client.
- Une commande peut avoir plusieurs articles, plusieurs paiements ou plusieurs avis : attention aux doublons lors des jointures.
- Dates au format texte, valeurs manquantes sur les dates de livraison (commandes non livrées).
- Colonnes `product_name_lenght` et `product_description_lenght` : l'orthographe « lenght » vient de la source.
