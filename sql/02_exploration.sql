-- Combien y a-t-il de customer_id distincts et de customer_unique_id distincts ? Que remarquez-vous, et pourquoi est-ce important pour compter des clients ?

SELECT COUNT(DISTINCT customer_id) as customer_id_count,

       COUNT(DISTINCT customer_unique_id) as customer_unique_id_count FROM customers;


-- Quelles sont la première et la dernière date d'achat ? 


SELECT MIN(order_purchase_timestamp) as first_purchase_date,

       MAX(order_purchase_timestamp) as last_purchase_date FROM orders;


-- Quel pourcentage des commandes n'a pas le statut delivered ?

SELECT ROUND(100.0 * SUM(CASE WHEN order_status != 'delivered' THEN 1 ELSE 0 END) / COUNT(*), 2) as percentage_not_delivered
FROM orders;