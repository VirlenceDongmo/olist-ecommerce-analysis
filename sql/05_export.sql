SELECT o.order_id,
       o.order_status,
       strftime('%Y-%m', o.order_purchase_timestamp) AS mois_achat,
       i.nb_articles,
       i.montant,
       i.frais_port,
       -- nouvelles colonnes
       date(o.order_estimated_delivery_date)         AS date_livraison_estimee,
       date(o.order_delivered_customer_date)         AS date_livraison_reelle,
       CAST(julianday(date(o.order_delivered_customer_date))
          - julianday(date(o.order_estimated_delivery_date)) AS INTEGER) AS retard_jours,
       r.review_score                                AS note_client,
       c.customer_city                               AS ville,
       c.customer_state                              AS etat,
       t.product_category_name_english               AS categorie
FROM orders o
LEFT JOIN (SELECT order_id,
                  COUNT(*)                     AS nb_articles,
                  ROUND(SUM(price), 2)         AS montant,
                  ROUND(SUM(freight_value), 2) AS frais_port
           FROM order_items
           GROUP BY order_id) i
       ON o.order_id = i.order_id
LEFT JOIN customers c
       ON o.customer_id = c.customer_id
LEFT JOIN (SELECT order_id, review_score
           FROM (SELECT order_id, review_score,
                        ROW_NUMBER() OVER (PARTITION BY order_id
                                           ORDER BY review_creation_date DESC,
                                                    review_answer_timestamp DESC) AS rn
                 FROM order_reviews)
           WHERE rn = 1) r
       ON o.order_id = r.order_id
LEFT JOIN (SELECT order_id, product_id
           FROM (SELECT order_id, product_id,
                        ROW_NUMBER() OVER (PARTITION BY order_id
                                           ORDER BY price DESC, order_item_id) AS rn
                 FROM order_items)
           WHERE rn = 1) top
       ON o.order_id = top.order_id
LEFT JOIN products p
       ON top.product_id = p.product_id
LEFT JOIN product_category_translation t
       ON p.product_category_name = t.product_category_name
WHERE strftime('%Y-%m', o.order_purchase_timestamp) BETWEEN '2017-01' AND '2018-08';