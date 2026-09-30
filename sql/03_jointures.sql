-- Mission 2a : effet de la jointure orders / order_items
-- nb_lignes > nb_commandes car une commande de N articles apparait sur N lignes
SELECT COUNT(*) AS nb_lignes,
       COUNT(DISTINCT o.order_id) AS nb_commandes
FROM orders o
JOIN order_items i ON o.order_id = i.order_id;

-- Mission 2b : quelles commandes n'ont aucun article ?
-- LEFT JOIN garde toutes les commandes ; WHERE i.order_id IS NULL isole celles sans article
SELECT o.order_status,
       COUNT(*) AS nb_commandes_sans_article
FROM orders o
LEFT JOIN order_items i ON o.order_id = i.order_id
WHERE i.order_id IS NULL
GROUP BY o.order_status
ORDER BY nb_commandes_sans_article DESC;