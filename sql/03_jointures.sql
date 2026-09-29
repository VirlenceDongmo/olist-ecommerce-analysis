-- les 10 États avec le plus de commandes.

SELECT customer_state, COUNT(*) as order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY customer_state
ORDER BY order_count DESC
LIMIT 10;

-- Effet de la jointure orders / order_items

SELECT COUNT(*) AS nb_lignes,
       COUNT(DISTINCT o.order_id) AS nb_commandes
FROM orders o
JOIN order_items i ON o.order_id = i.order_id;