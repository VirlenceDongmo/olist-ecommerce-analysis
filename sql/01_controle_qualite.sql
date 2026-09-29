-- Nombre de lignes par table
SELECT 'orders' AS table_name, COUNT(*) AS n FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers;

-- Répartition des statuts de commande
SELECT order_status, COUNT(*) AS n
FROM orders
GROUP BY order_status
ORDER BY n DESC;

-- Commandes livrées sans date de livraison (incohérence potentielle)
SELECT COUNT(*) AS livrees_sans_date
FROM orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL;

-- Commandes avec plusieurs avis (risque de doublons dans les jointures)
SELECT COUNT(*) AS commandes_multi_avis
FROM (SELECT order_id FROM order_reviews GROUP BY order_id HAVING COUNT(*) > 1);
