# Nivell 1 - Exercici 1

gcloud projects create sprint3-analytics-eltevnom \
  --name="Sprint3 Analytics" \
  

CREATE SCHEMA `sprint3-analytics-irinamihai.sprint3_silver`
OPTIONS (
  location = 'EU',
  description = 'Capa Silver: dades netes, tipades i deduplicades'
);

bq --location=EU mk --dataset \
  --description="Capa Gold: dades agregades per a informes i dashboards" \
  sprint3-analytics-irinamihai:sprint3_gold
  

# Nivell 1 - Exercici 2

CREATE OR REPLACE EXTERNAL TABLE `sprint3-analytics-irinamihai.sprint3_bronze.transactions_raw`
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/ERP/transactions.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1
);

CREATE OR REPLACE EXTERNAL TABLE `sprint3-analytics-irinamihai.sprint3_bronze.companies_raw`
(
  company_id STRING,
  company_name STRING,
  country STRING,
  industry STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/ERP/companies.csv'],
  skip_leading_rows = 1
);

# Nivell 1 - Exercici 3

# No hay código - carga del fichero via UI

# Nivell 1 - Exercici 4

CREATE OR REPLACE TABLE
  `sprint3-analytics-irinamihai`.`sprint3_bronze`.`transactions_raw_native` AS
SELECT
  id,
  card_id,
  business_id,
  timestamp,
  amount,
  declined,
  product_ids,
  user_id,
  lat,
  longitude
FROM
  `sprint3-analytics-irinamihai`.`sprint3_bronze`.`transactions_raw`;
  
  # Nivell 1 - Exercici 5

SELECT (EXTRACT (DAY FROM timestamp)) AS day, MAX(amount) AS tope_ingressos
FROM
  `sprint3-analytics-irinamihai`.`sprint3_bronze`.`transactions_raw_native`
  WHERE EXTRACT (YEAR FROM timestamp) = 2021
  AND declined=0
  GROUP BY day
  ORDER BY tope_ingressos DESC
LIMIT
  5;
  
  # Nivell 1 - Exercici 6
  
  # Llista el nom, país i data de les transaccions realitzades per empreses 
  # que van fer operacions entre 100 i 200 euros 
  # en alguna d'aquestes dates: 29-04-2015, 20-07-2018 o 13-03-2024.
  
SELECT companies_raw.company_name, companies_raw.country, FORMAT_TIMESTAMP("%Y-%m-%d", timestamp) as date
FROM sprint3_bronze.companies_raw
JOIN sprint3_bronze.transactions_raw as tr
ON companies_raw.company_id = tr.business_id
WHERE DATE(tr.timestamp) IN ("2015-04-29", "2018-07-20","2024-03-13") AND amount BETWEEN 100 AND 200
AND declined=0;

# Nivell 2 - Exercici 1a

CREATE OR REPLACE TABLE sprint3-analytics-irinamihai.sprint3_silver.products_clean AS

SELECT 
id AS product_id,
product_name AS name,
price,
colour,
weight,
warehouse_id,
brand,
cost,
launch_date

FROM sprint3-analytics-irinamihai.sprint3_bronze.products_raw

# Nivell 2 - Exercici 1b,c,d

CREATE OR REPLACE TABLE sprint3-analytics-irinamihai.sprint3_silver.products_clean AS
SELECT
  id AS product_id,
  product_name AS name,
  SAFE_CAST(REGEXP_REPLACE(price,r'[^0-9,-]','') AS FLOAT64) AS price,
  colour,
  weight,
  SAFE_CAST(REPLACE(warehouse_id,'WH-','') AS INT64) AS warehouse_id,
  brand,
  cost,
  launch_date
FROM sprint3-analytics-irinamihai.sprint3_bronze.products_raw


# Nivell 2 - Exercici 2a, b, c, d, e, f

CREATE OR REPLACE TABLE sprint3-analytics-irinamihai.sprint3_silver.transactions_clean AS
SELECT
  id AS transaction_id,
  card_id,
  business_id,
  timestamp,
  IFNULL(SAFE_CAST(amount AS FLOAT64), 0) AS amount,
  declined,
 ARRAY(
    SELECT SAFE_CAST(TRIM(id_str) AS INT64)
    FROM UNNEST(SPLIT(product_ids, ',')) AS id_str
  ) AS product_id,
  user_id,
  SAFE_CAST(lat AS FLOAT64) AS lat,
  SAFE_CAST(longitude AS FLOAT64) AS longitude


FROM sprint3-analytics-irinamihai.sprint3_bronze.transactions_raw

# Nivell 2 - Exercici 3

CREATE OR REPLACE TABLE sprint3-analytics-irinamihai.sprint3_silver.users_combined AS
SELECT
id as user_id,
name,
surname,
phone,
email,
birth_date,
country,
city,
postal_code,
address,
"America" AS origin
FROM sprint3-analytics-irinamihai.sprint3_bronze.american_users_raw
UNION ALL
SELECT
id as user_id,
name,
surname,
phone,
email,
birth_date,
country,
city,
postal_code,
address,
"Europe" AS origin
FROM sprint3-analytics-irinamihai.sprint3_bronze.european_users_raw

# Nivell 2 - Exercici 4

-- 4.1 Creación tabla sprint3_silver.companies_clean

CREATE OR REPLACE TABLE sprint3-analytics-irinamihai.sprint3_silver.companies_clean AS
SELECT
  company_id,
  company_name,
  phone,
  e-mail,
  country,
  website
FROM
  sprint3-analytics-irinamihai.sprint3_bronze.credit_cards_raw;


-- 4.2 Creación tabla sprint3_silver.companies_clean

CREATE OR REPLACE TABLE sprint3-analytics-irinamihai.sprint3_silver.credit_cards_clean AS
SELECT
  id AS card_id,
  user_id,
  iban,
  pan,
  pin,
  cvv,
  track1,
  track2,
  expiring_date
FROM
  sprint3-analytics-irinamihai.sprint3_bronze.credit_cards_raw;

# Nivell 3 - Exercici 1

CREATE OR REPLACE VIEW sprint3_gold.v_marketing_kpis(company_name, phone, country, avg_amount, client_tier) AS 
SELECT company_name, phone, country, AVG(amount) as avg_amount,
CASE WHEN AVG(amount) > 260 THEN 'Premium'
WHEN AVG(amount) <= 260 THEN 'Standard'
END AS client_tier
FROM sprint3_silver.companies_clean
JOIN sprint3_silver.transactions_clean
ON companies_clean.company_id = transactions_clean.business_id
GROUP BY company_name, phone, country

SELECT * FROM sprint3_gold.v_marketing_kpis
ORDER BY avg_amount DESC;

# Nivell 3 - Exercici 2

CREATE OR REPLACE TABLE `sprint3-analytics-irinamihai.sprint3_gold.product_sales_ranking` AS
SELECT
  p.product_id,
  p.name,
  p.price,
  p.colour,
  COUNT(*) AS total_sold
FROM `sprint3-analytics-irinamihai.sprint3_silver.transactions_clean` AS t,
  UNNEST(t.product_id) AS sold_product_id
JOIN `sprint3-analytics-irinamihai.sprint3_silver.products_clean` AS p
  ON p.product_id = sold_product_id
GROUP BY p.product_id, p.name, p.price, p.colour
ORDER BY total_sold DESC;

# Nivell 3 - Exercici 3

SELECT * FROM `sprint3-analytics-irinamihai.sprint3_gold.product_sales_ranking`;





