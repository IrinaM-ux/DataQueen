# Nivell 1 - Exercici 8

CREATE DATABASE IF NOT EXISTS irinasdatabase;
USE irinasdatabase;

CREATE TABLE IF NOT EXISTS transactions (
        id VARCHAR(60) NOT NULL,
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
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
IGNORE 1 ROWS
(id, card_id, business_id, timestamp, amount, declined, product_ids, user_id, lat, longitude, discount_amount, tax_amount, shipping_amount, channel, campaign_id, device_type, is_international, decline_reason, distance_km);
    
CREATE TABLE IF NOT EXISTS companies (
    
        company_id VARCHAR(60) NOT NULL,
        company_name VARCHAR(60),
        phone VARCHAR(60),
        email VARCHAR(60),
        country VARCHAR(60),
        website VARCHAR(60),
        merchant_category VARCHAR(60),
        merchant_price_position VARCHAR(60)
    );
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS
(company_id, company_name, phone, email, country, website, merchant_category, merchant_price_position);

    CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(60) NOT NULL,
        name VARCHAR(60),
        surname VARCHAR(60),
        phone VARCHAR(60),
        email VARCHAR(60),
        birth_date VARCHAR(60),
        country VARCHAR(60),
        city VARCHAR(60),
        postal_code VARCHAR(60),
        address VARCHAR(60),
        signup_date DATE,
        user_segment VARCHAR(60),
        income_band VARCHAR(10),
        region VARCHAR(10)
        );
        
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS
(id,name,surname,phone,email,birth_date,country,city,postal_code,address,signup_date,user_segment,income_band)
SET region = "Europe";

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS
(id,name,surname,phone,email,birth_date,country,city,postal_code,address,signup_date,user_segment,income_band)
SET region = "America";

        
CREATE TABLE IF NOT EXISTS credit_cards (
        id VARCHAR(60) NOT NULL,
        user_id INT NOT NULL,
        iban VARCHAR(60),
        pan VARCHAR(60),
        pin INT,
        cvv INT,
        track1 VARCHAR(255),
        track2 VARCHAR(255),
        expiring_date VARCHAR(60),
        card_type VARCHAR(60),
        card_renewal_flag TINYINT
        );
        
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS
(id,user_id,iban,pan,pin,cvv,track1,track2,expiring_date,card_type,card_renewal_flag);

ALTER TABLE users
ADD PRIMARY KEY (id);

ALTER TABLE transactions
ADD PRIMARY KEY (id);

ALTER TABLE credit_cards
ADD PRIMARY KEY (id);

ALTER TABLE companies
ADD PRIMARY KEY (company_id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_user
FOREIGN KEY (user_id)
REFERENCES users(id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_card
FOREIGN KEY (card_id)
REFERENCES credit_cards (id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_company
FOREIGN KEY (business_id)
REFERENCES companies (company_id);

ALTER TABLE transactions
MODIFY COLUMN user_id VARCHAR(60);
    


