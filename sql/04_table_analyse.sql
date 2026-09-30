-- Table d'analyse, etape 1 : montant par commande (1 ligne = 1 commande)
SELECT o.order_id,
       o.order_status,
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



-- Table d'analyse, etape 2 : ajout du mois d'achat
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





-- Commandes par mois (verification de la periode)
SELECT strftime('%Y-%m', order_purchase_timestamp) AS mois_achat,
       COUNT(*) AS nb_commandes
FROM orders
GROUP BY mois_achat
ORDER BY mois_achat;




SELECT COUNT(DISTINCT strftime('%Y-%m', order_purchase_timestamp)) AS nb_mois,
       SUM(strftime('%Y-%m', order_purchase_timestamp) IS NULL) AS dates_vides
FROM orders;




-- 1. Nombre de lignes (attendu : 99441)
SELECT COUNT(*) FROM (SELECT o.order_id,
       o.order_status,
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
       ON o.order_id = i.order_id);

-- 2. Somme des montants = somme des prix source
SELECT SUM(price) FROM order_items;
SELECT SUM(montant) FROM (SELECT o.order_id,
       o.order_status,
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
       ON o.order_id = i.order_id);

-- 3. Commandes sans montant (attendu : 775)
SELECT COUNT(*) FROM (SELECT o.order_id,
       o.order_status,
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
       ON o.order_id = i.order_id) WHERE montant IS NULL;