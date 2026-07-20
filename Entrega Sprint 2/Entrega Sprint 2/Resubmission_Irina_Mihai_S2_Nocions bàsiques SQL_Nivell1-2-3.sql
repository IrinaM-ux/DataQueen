# Tasca S2.01. Nocions bàsiques SQL


# Nivell 1 - Exercici 1

# 1.1 -  A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules. 
# 1.2 - Mostra les característiques principals de l'esquema creat i 
# explica les diferents taules i variables que existeixen. 
# 1.3 - Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.

CREATE DATABASE IF NOT EXISTS transactions;
    USE transactions;

CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) NOT NULL,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255),
        PRIMARY KEY(id)
    );
 
 CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) NOT NULL,
        credit_card_id VARCHAR(15),
        company_id VARCHAR(20) NOT NULL, 
        user_id INT,
        lat DECIMAL(10,2)
        longitude DECIMAL(10,2),
        'timestamp' DATETIME,
        amount DECIMAL(10, 2),
        declined TINYINT(1)
        PRIMARY KEY (id),
        CONSTRAINT fk_transaction_company
        FOREIGN KEY (company_id)
        REFERENCES company(id)
    );
    
SHOW CREATE TABLE company;

SHOW CREATE TABLE transaction

# Nivell 1 - Exercici 2

# Utilitzant JOIN realitzaràs les següents consultes:

# 2.1 - Llistat dels països que estan generant vendes.

SELECT DISTINCT(country)
FROM transactions.company
JOIN transactions.transaction
ON transaction.company_id = company.id
WHERE declined=0;

# 2.2 -  Des de quants països es generen les vendes.

SELECT COUNT(DISTINCT country) AS Num_paises
FROM transactions.company
JOIN transactions.transaction
ON transaction.company_id = company.id
WHERE declined=0;

# 2.3 - Identifica la companyia amb la mitjana més gran de vendes.

SELECT ROUND(AVG(amount),2) AS Media_ventas, company_name
FROM transactions.company
JOIN transactions.transaction
ON transaction.company_id = company.id
WHERE declined = 0
GROUP BY company_name
ORDER BY AVG(amount) DESC
LIMIT 1;

# Nivell 1 - Exercici 3

# 3.1 - Mostra totes les transaccions realitzades per empreses d'Alemanya.

SELECT *
FROM transaction
WHERE company_id IN (SELECT id FROM company WHERE country = "Germany")
AND declined = 0;

# 3.2 - Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT company_id, (SELECT company_name FROM company t WHERE t.id = company_id )
FROM transaction
WHERE amount > (SELECT AVG(amount) AS Mitjana FROM transaction)
AND declined = 0
GROUP BY company_id;

# 3.3 - Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

SELECT id, company_name
FROM company AS c
WHERE id NOT IN (SELECT company_id FROM transaction AS t WHERE c.id = t.company_id );

DELETE FROM company
WHERE id NOT IN (SELECT company_id FROM transaction AS t WHERE company.id = t.company_id );


# Nivell 1 - Exercici 4

CREATE TABLE IF NOT EXISTS credit_card (
        id VARCHAR(60) PRIMARY KEY,
        iban VARCHAR(60),
        pan VARCHAR(60),
        pin VARCHAR(60),
        cvv VARCHAR(60),
        expiring_date VARCHAR(60)
    );

-- Propuesta de mejora creación tabla:

CREATE TABLE IF NOT EXISTS credit_card (
        id VARCHAR(8) PRIMARY KEY,
        iban VARCHAR(24),
        pan VARCHAR(60),
        pin INT(4),
        cvv INT(3),
        expiring_date DATE
        );
-- Propuesta modificación tabla existente

ALTER TABLE credit_card
MODIFY COLUMN id VARCHAR(8),
MODIFY COLUMN iban VARCHAR(24),
MODIFY COLUMN pin INT(4),
MODIFY COLUMN cvv INT(3),
MODIFY COLUMN expiring_date DATE;


# Nivell 1 - Exercici 5

UPDATE credit_card
SET iban = "TR323456312213576817699999"
WHERE id = "CcU-2938";



# Nivell 1 - Exercici 6

INSERT INTO credit_card (id) VALUES ("CcU-9999");
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", 
"b-9999", "9999", "829.999", "-117.999", "111.11", "0")

-- He tenido que crear un nuevo id de empresa utilizando este código:

INSERT INTO company (id) VALUES ("b-9999");


# Nivell 1 - Exercici 7

ALTER TABLE credit_card
DROP COLUMN pan;

# Nivell 1 - Exercici 8

# Las tablas companies y credit_cards se han creado similar a la tabla transactions.

CREATE TABLE IF NOT EXISTS transactions (
        id VARCHAR(60) PRIMARY KEY,
        card_id VARCHAR(60),
        business_id VARCHAR(60),
        timestamp VARCHAR(60),
        amount DECIMAL(10,2),
        declined TINYINT(1),
        product_ids VARCHAR(60),
        user_id INT,
        lat DECIMAL(10,2),
        longitude DECIMAL(10,2),
        discount_amount FLOAT,
        tax_amount FLOAT,
        shipping_amount FLOAT,
        channel VARCHAR(60),
        campaign_id VARCHAR(60),
        device_type VARCHAR(60),
        is_international VARCHAR(60),
        decline_reason VARCHAR(60),
        distance_km DECIMAL(10,2)
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

SHOW CREATE TABLE companies

SHOW CREATE TABLE credit_cards

LOAD DATA LOCAL INFILE 'C:/Users/irina/Desktop/DATA/DATA ANALIST IT ACADEMY/ESPECIALITZACIO/SPRINT 2/N1-Ex.8__european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
SET origin = "Europe";

LOAD DATA LOCAL INFILE 'C:/Users/irina/Desktop/DATA/DATA ANALIST IT ACADEMY/ESPECIALITZACIO/SPRINT 2/N1-Ex.8__american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
SET origin = "America";

SET GLOBAL local_infile = 1;


# Nivell 1 - Exercici 9

# Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.

SELECT id, name, surname
FROM users as u
WHERE id IN (
		SELECT user_id FROM transactions AS t GROUP BY t.user_id HAVING COUNT(id) > 80);
        
        
        
        
        
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
WHERE declined=0
GROUP BY DATE(timestamp)
ORDER BY Total_vendes_per_dia desc
LIMIT 5

# Nivell 2  - Exercici 2

# Presenta el nom, telèfon, país, data i amount, 
# d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros 
# i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. 
# Ordena els resultats de major a menor quantitat.

SELECT

    c.company_name,

    c.phone,

    c.country,

    DATE(t.`timestamp`) AS transaction_date,

    t.amount

FROM companies AS c

JOIN transactions AS t

    ON t.business_id = c.company_id

WHERE t.amount BETWEEN 350 AND 400

  AND DATE(t.`timestamp`) IN (

      '2015-04-29',

      '2018-07-20',

      '2024-03-13'

  )

ORDER BY t.amount DESC;


# Nivell 2 - Exercici 3

# Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
# per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
# però el departament de recursos humans és exigent i vol un llistat de les empreses 
# on especifiquis si tenen igual o més de 400 transaccions o menys.

SELECT c.company_name,

    COUNT(t.id) AS total_transacciones,

    CASE

        WHEN COUNT(t.id) >= 400

            THEN 'Igual o más de 400'

        ELSE 'Menos de 400'

    END AS nivel_transacciones

FROM companies AS c

LEFT JOIN transactions AS t

    ON t.business_id = c.company_id

GROUP BY c.company_id, c.company_name

ORDER BY total_transacciones DESC;


# Nivell 2 - Exercici 4

# Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.

DELETE FROM transactions
WHERE id = "000447FE-B650-4DCF-85DE-C7ED0EE1CAAD"

# Nivell 2 - Exercici 5

# Serà necessària que creïs una vista anomenada VistaMarketing 
# que contingui la següent informació: 
# Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
# Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.

CREATE OR REPLACE VIEW VistaMarketing AS
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


CREATE TABLE credit_card_status AS

SELECT transactions.credit_card_id AS credit_card_id, 

    CASE

        WHEN SUM(transactions.declined) = 3 THEN 'inactive' ELSE 'active'

    END AS status

FROM

    (SELECT transactions.credit_card_id, transactions.declined,

        ROW_NUMBER() OVER(PARTITION BY transactions.credit_card_id ORDER BY t.timestamp DESC) AS rn

    FROM transactions t) trans

WHERE transactions.rn <= 3

GROUP BY trans.credit_card_id;




SELECT COUNT(*) AS active_qty

FROM credit_card_status

WHERE status='active';
 

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
