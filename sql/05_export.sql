SELECT o.order_id,
       o.order_status,
       strftime('%Y-%m', o.order_purchase_timestamp) AS mois_achat,
       i.nb_articles,
       i.montant,
       i.frais_port
FROM orders o
LEFT JOIN (SELECT order_id,
                  COUNT(*)                     AS nb_articles,
                  ROUND(SUM(price), 2)         AS montant,
                  ROUND(SUM(freight_value), 2) AS frais_port
           FROM order_items
           GROUP BY order_id) i
       ON o.order_id = i.order_id;