# Tasca S2.01. Nocions bàsiques SQL


# Nivell 1 - Exercici 1

# A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules. 
# Mostra les característiques principals de l'esquema creat i 
# explica les diferents taules i variables que existeixen. 
# Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.

CREATE DATABASE IF NOT EXISTS transactions;
    USE transactions;

CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );
 
 CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        credit_card_id VARCHAR(15) REFERENCES credit_card(id),
        company_id VARCHAR(20), 
        user_id INT REFERENCES user(id),
        lat FLOAT,
        longitude FLOAT,
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        FOREIGN KEY (company_id) REFERENCES company(id) 
    );
    
USE transactions;


ALTER TABLE transaction
DROP CONSTRAINT fk_company


ALTER TABLE transaction
ADD CONSTRAINT fk_company
FOREIGN KEY (company_id) REFERENCES company(id);

# Nivell 1 - Exercici 2

# Utilitzant JOIN realitzaràs les següents consultes:

# Llistat dels països que estan generant vendes.
# Des de quants països es generen les vendes.
# Identifica la companyia amb la mitjana més gran de vendes.

SELECT DISTINCT country
FROM transactions.company
JOIN transactions.transaction
ON transaction.company_id = company.id
WHERE declined = 0
ORDER BY 


SELECT COUNT(DISTINCT country)
FROM transactions.company
JOIN transactions.transaction
ON transaction.company_id = company.id
WHERE declined = 0;


SELECT AVG (amount), company_name
FROM transactions.company
JOIN transactions.transaction
ON transaction.company_id = company.id
WHERE declined = 0
GROUP BY company_name
ORDER BY AVG(amount) DESC
LIMIT 1

# Nivell 1 - Exercici 3

SELECT *
FROM transaction
WHERE company_id IN (SELECT id FROM company WHERE country = "Germany")
AND declined = 0;


SELECT DISTINCT company_id
FROM transaction
WHERE amount > (SELECT AVG(amount) AS Mitjana FROM transaction)


SELECT company_name
FROM company
WHERE id IN (SELECT company_id FROM transaction WHERE id is null);

DELETE FROM company
WHERE id IN (SELECT company_id FROM transaction WHERE id is null);

# Nivell 1 - Exercici 4

CREATE TABLE IF NOT EXISTS credit_card (
        id VARCHAR(60) PRIMARY KEY,
        iban VARCHAR(60),
        pan VARCHAR(60),
        pin VARCHAR(60),
        cvv VARCHAR(60),
        expiring_date VARCHAR(60)
    );
    

ALTER TABLE transaction
ADD CONSTRAINT fk_card
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);


# Nivell 1 - Exercici 5

UPDATE credit_card
SET iban = "TR323456312213576817699999"
WHERE id = "CcU-2938";

# Nivell 1 - Exercici 6

INSERT INTO credit_card (id) VALUES ("CcU-9999");
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", 
"b-9999", "9999", "829.999", "-117.999", "111.11", "0");

# Nivell 1 - Exercici 7

ALTER TABLE credit_card
DROP COLUMN pan;

# Nivell 1 - Exercici 8

# Las tablas companies y credit_cards se han creado similar a la tabla transactions.

CREATE TABLE IF NOT EXISTS transactions (
        id VARCHAR(60),
        card_id VARCHAR(60),
        business_id VARCHAR(60),
        timestamp VARCHAR(60),
        amount FLOAT,
        declined VARCHAR(60),
        product_ids VARCHAR(60),
        user_id INT,
        lat FLOAT,
        longitude FLOAT,
        discount_amount FLOAT,
        tax_amount FLOAT,
        shipping_amount FLOAT,
        channel VARCHAR(60),
        campaign_id VARCHAR(60),
        device_type VARCHAR(60),
        is_international VARCHAR(60),
        decline_reason VARCHAR(60),
        distance_km FLOAT
    );

    
    CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(60) PRIMARY KEY,
        name VARCHAR(60),
        surname VARCHAR(60),
        phone VARCHAR(60),
        email VARCHAR(60),
        birth_date VARCHAR(60),
        country VARCHAR(60),
        city VARCHAR(60),
        postal_code VARCHAR(60),
        address VARCHAR(60),
        signup_date VARCHAR(60),
        user_segment VARCHAR(60),
        income_band VARCHAR(60),
        region VARCHAR(60)
        );
	

LOAD DATA LOCAL INFILE 'C:/Users/irina/Desktop/DATA/DATA ANALIST IT ACADEMY/ESPECIALITZACIO/SPRINT 2/N1-Ex.8__european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS


SET GLOBAL local_infile = 1;


ALTER TABLE transactions
DROP CONSTRAINT fk_company;

ALTER TABLE transactions
DROP CONSTRAINT fk_card;

ALTER TABLE transactions
MODIFY COLUMN user_id VARCHAR(60);

ALTER TABLE transactions
ADD CONSTRAINT fkey_company
FOREIGN KEY (business_id) REFERENCES companies(company_id);

ALTER TABLE transactions
ADD CONSTRAINT fkey_card
FOREIGN KEY (card_id) REFERENCES credit_cards(id);

ALTER TABLE users
ADD COLUMN region VARCHAR(60);

ALTER TABLE transactions
ADD CONSTRAINT fkey_user
FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE users
ADD PRIMARY KEY (id);




# Nivell 1 - Exercici 9

# Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.

SELECT id, name, surname
FROM users
WHERE id IN (
		SELECT user_id
        FROM (SELECT COUNT(id) AS Num_trans, user_id FROM transactions GROUP BY user_id HAVING COUNT(id) > 80) t1
        );
        
        
# Nivell 1 - Exercici 10

# Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.  

SELECT AVG(amount), iban
FROM transactions
JOIN credit_cards
ON credit_cards.id = transactions.card_id
JOIN companies
ON companies.company_id = transactions.business_id
WHERE company_name = "Donec Ltd"
GROUP BY iban;


# Nivell 2  - Exercici 1

# Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
# Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT DATE(timestamp) as Dia, SUM(amount) AS Total_vendes_per_dia
FROM transactions 
GROUP BY DATE(timestamp)
ORDER BY Total_vendes_per_dia desc
LIMIT 5

# Nivell 2  - Exercici 2

# Presenta el nom, telèfon, país, data i amount, 
# d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros 
# i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. 
# Ordena els resultats de major a menor quantitat.

SELECT company_name, phone, country, amount
FROM companies
JOIN transactions
ON companies.company_id = transactions.business_id
WHERE timestamp IN (SELECT DATE(timestamp) FROM transactions WHERE DATE(timestamp) IN ("2015-04-29", "2018-07-20", "2024-03-13") AND declined = 0)
AND amount BETWEEN 350 and 400
ORDER BY amount desc;



# Nivell 2 - Exercici 3

# Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
# per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
# però el departament de recursos humans és exigent i vol un llistat de les empreses 
# on especifiquis si tenen igual o més de 400 transaccions o menys.

SELECT companies.company_name, t1.purchases,
CASE
	WHEN t1.purchases > 400 THEN "Above 400"
	WHEN t1.purchases < 400 THEN "Below 400"
    WHEN t1.purchases = 400 THEN "400"
END AS transaction_level
FROM (SELECT COUNT(id) AS purchases, business_id FROM transactions GROUP BY business_id) as t1
JOIN companies
ON companies.company_id = t1.business_id;


# Nivell 2 - Exercici 4

# Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.

DELETE FROM transactions
WHERE id = "000447FE-B650-4DCF-85DE-C7ED0EE1CAAD"

# Nivell 2 - Exercici 5

# Serà necessària que creïs una vista anomenada VistaMarketing 
# que contingui la següent informació: 
# Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
# Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.

SELECT company_name, phone, country, AVG(amount) AS mitjana_compra
FROM companies
JOIN transactions
ON companies.company_id = transactions.business_id
GROUP BY company_name, phone, country
ORDER BY mitjana_compra desc;


# Nivell 3 - Exercici 1

# Crea una nova taula que reflecteixi l'estat de les targetes de crèdit 
# basat en si les tres últimes transaccions han estat declinades aleshores és inactiu, 
# si almenys una no és rebutjada aleshores és actiu.

# Partint d’aquesta taula respon: 👉 Quantes targetes estan actives?


SELECT COUNT(card_id),
CASE
	WHEN SUM(declined=0) = 0 THEN "Inactive"
	ELSE "Active"
	END AS situacio
FROM (
SELECT card_id, timestamp, declined,
ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS R_N
FROM transactions) AS posicio
WHERE R_N <= 3;

# Nivell 3 - Exercici 2

# Crea una taula amb la qual puguem unir les dades de l'arxiu de products.csv 
# amb la base de dades creada
# (ja que fins ara no podíem fer-ho),
#  tenint en compte que des de transaction tens product_ids. 
# Genera la següent consulta:
# Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
    
 CREATE TABLE IF NOT EXISTS products (
	id INT,
    product_name VARCHAR(60),
    price DECIMAL(10, 2),
    colour VARCHAR(60),
    weight FLOAT,
    warehouse_id VARCHAR(60),
    category VARCHAR(60),
    brand VARCHAR(60),
    cost DECIMAL(10, 2),
    launch_date DATE
    );
    
LOAD DATA LOCAL INFILE 'C:/Users/irina/Desktop/DATA/DATA ANALIST IT ACADEMY/ESPECIALITZACIO/SPRINT 2/N1-Ex.8__products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, product_name, @price, colour, weight, warehouse_id, category, brand, @cost, launch_date)
SET 
    price = REPLACE(@price, '$', ''),
    cost = REPLACE(@cost, '$', '');
    
    
SELECT p.product_name, COUNT(*) AS vendes
FROM transaction_products tp
JOIN products p ON tp.product_id = p.id
GROUP BY p.product_name
ORDER BY vendes DESC;

JOIN JSON_TABLE(
CONCAT('[', product_ids, ']'),
    '$[*]' COLUMNS (product_id INT PATH '$')
) jt

















        
        
CREATE DATABASE IF NOT EXISTS transactions;
