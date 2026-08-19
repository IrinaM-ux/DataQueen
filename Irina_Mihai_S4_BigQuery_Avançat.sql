# Nivell 1 - Exercici 1

SELECT *
FROM sprint3_silver.transactions_clean
JOIN sprint3_silver.companies_clean
ON transactions_clean.business_id = companies_clean.company_id
WHERE country = "Germany"
AND declined=0
AND DATE(timestamp) = "2022-03-12"

# Nivell 1 - Exercici 2

# Exercici 2.1 - Crear tabla _recent

CREATE OR REPLACE TABLE sprint3_silver.transactions_recent AS
SELECT * EXCEPT (timestamp), TIMESTAMP_SUB(timestamp, INTERVAL CAST (RAND() * 50 AS INT64) DAY) AS timestamp
FROM sprint3_silver.transactions_clean;

# Exercici 2.2 - Crear tabla _optimized con PARTITION BY + CLUSTER BY

CREATE OR REPLACE TABLE sprint3_gold.fact_transactions_optimized
PARTITION BY DATE(timestamp)
CLUSTER BY business_id 
AS
SELECT * FROM sprint3_silver.transactions_recent;

# Nivell 1 - Exercici 3

SELECT *
FROM sprint3_gold.fact_transactions_optimized
WHERE timestamp >=TIMESTAMP_SUB((SELECT MAX(timestamp) FROM sprint3_silver.transactions_recent), INTERVAL 30 DAY) AND declined = 0;

# Nivell 1 - Exercici 4

CREATE MATERIALIZED VIEW sprint3_gold.mv_daily_sales AS
SELECT DATE(timestamp) AS date, SUM(amount) AS total_sales
FROM sprint3_silver.transactions_clean
WHERE declined=0
GROUP BY DATE(timestamp);

# Nivell 2 - Exercici 1

WITH VIP_Stats AS (
SELECT user_id, SUM(amount) AS total_gastat, COUNT(transaction_id) AS num_compres, ROUND(AVG(amount),2) AS tiquet_mig, MAX(amount) AS max_compra
FROM sprint3_silver.transactions_recent AS t
WHERE declined=0
GROUP BY user_id
HAVING total_gastat > 500)

SELECT user_id, CONCAT (name, " ", surname) AS nom_complet, country , email, num_compres, tiquet_mig, max_compra, total_gastat
FROM VIP_Stats
JOIN sprint3_silver.users_combined AS u
USING (user_id)
ORDER BY total_gastat DESC;

# Nivell 2 - Exercici 2

SELECT date, ROUND(total_sales,2) AS vendes_avui,
ROUND(LAG (total_sales) OVER (ORDER BY date),2)
AS vendes_ahir,
ROUND ((total_sales - LAG (total_sales) OVER (ORDER BY date))/ LAG (total_sales) OVER (ORDER BY date) * 100, 2) AS variacio_percentual
FROM sprint3_gold.mv_daily_sales
ORDER BY date desc;

# Nivell 2 - Exercici 3

SELECT date, ROUND(total_sales,2)
AS vendes_dia,
ROUND (SUM(total_sales) OVER (PARTITION BY EXTRACT (YEAR FROM date) ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS vendes_acumulades_YTD
FROM sprint3_gold.mv_daily_sales
ORDER BY date desc;

# Nivell 2 - Exercici 4

# Genera un llistat dels usuaris que han arribat (o superat) la seva tercera compra, mostrant:
# 1.Dades d'usuari (user_id, nom_complet, email).
# 2.La data i l'import exacte de la 3a compra.
# 3.Mitjana de les 3 primeres: La mitjana de despesa de les seves transaccions 1, 2 i 3.

WITH tercera_compra AS (

SELECT

  t.timestamp,
  t.amount,
  c.user_id,
  ROW_NUMBER() OVER (PARTITION BY c.user_id ORDER BY t.timestamp) AS num_compra

FROM sprint3-analytics-irinamihai.sprint3_gold.fact_transactions_optimized AS t
JOIN sprint3-analytics-irinamihai.sprint3_silver.credit_cards_clean AS c
ON t.card_id = c.card_id

QUALIFY num_compra <= 3

),

media_user AS (

SELECT t.user_id, ROUND(AVG(t.amount), 2) AS media_3compras
FROM tercera_compra t
GROUP BY 1

)

SELECT
  u.user_id,
  CONCAT(u.name, " ", u.surname) AS nom_complet,
  u.email,
  DATE(t.timestamp) AS fecha_3a_compra,
  t.amount AS importe_3a_compra,
  m.media_3compras

FROM tercera_compra t
JOIN media_user m
ON t.user_id = m.user_id

JOIN sprint3-analytics-irinamihai.sprint3_silver.users_combined u
ON t.user_id = u.user_id

ORDER BY timestamp DESC;


# Nivell 3 - Exercici 1

CREATE OR REPLACE TABLE sprint3_gold.dim_transactions_flat AS
SELECT 
t.transaction_id,
t.timestamp, 
t.amount AS total_ticket,
p.name AS product_name, 
p.price AS product_price,
CAST(product_id AS string) AS product_sku
FROM sprint3-analytics-irinamihai.sprint3_gold.fact_transactions_optimized t
CROSS JOIN
UNNEST(t.product_id) AS product_id,
JOIN sprint3_silver.products_clean p,
ON CAST(product_id AS STRING) = CAST(p.product_id AS STRING);

# Nivell 3 - Exercici 2

SELECT COUNT(*), product_name 
FROM `sprint3-analytics-irinamihai.sprint3_gold.dim_transactions_flat`
GROUP BY product_name
ORDER BY COUNT(*) DESC
LIMIT 5;

# Nivell 3 - Exercici 3

# 3.1

CREATE OR REPLACE FUNCTION
`sprint3-analytics-irinamihai.sprint3_gold.calculate_tax`(total FLOAT64)
RETURNS FLOAT64
AS (total*1.21);


CREATE OR REPLACE TABLE `sprint3-analytics-irinamihai`.`sprint3_gold`.`dim_transactions_flat` AS
SELECT 
  t.transaction_id,
  t.transaction_timestamp, 
  t.amount AS total_ticket,
  CAST(product_id AS STRING) AS product_sku,
  p.name AS product_name,
  p.price AS product_price,
  `sprint3-analytics-irinamihai`.`sprint3_gold`.`calculate_tax`(p.price) AS product_price_tax_inc
FROM `sprint3-analytics-irinamihai`.`sprint3_gold`.`fact_transactions_optimized` t
CROSS JOIN
  UNNEST(t.product_id) AS product_id
JOIN `sprint3-analytics-irinamihai`.`sprint3_silver`.`products_clean` p
  ON CAST(product_id AS STRING) = CAST(p.product_id AS STRING);





