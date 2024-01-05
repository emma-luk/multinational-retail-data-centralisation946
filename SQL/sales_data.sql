-- Initialise a new database locally to store the extracted data.
-- Set up a new database within pgadmin4 and name it sales_data.
-- This database will store all the company information once you extract it for the various data sources.

-- This code will create a new database named "sales_data" in the current PostgreSQL instance. If you are using pgAdmin4, you can also create the database by following these steps:

-- Open pgAdmin4 and connect to your PostgreSQL server.
-- Right-click on the "Databases" node and select "Create".
-- In the "Create database" dialog box, enter "sales_data" as the name of the database.
-- Click "OK" to create the database.

-- Task 1: Set up a new database to store the data.
-- Initialise a new database locally to store the extracted data.
-- Set up a new database within pgadmin4 and name it sales_data.
-- This database will store all the company information once you extract it for the various data sources.

CREATE DATABASE sales_data
WITH
OWNER = postgres
ENCODING = 'UTF8'
LOCALE_PROVIDER = 'libc'
CONNECTION LIMIT = -1
IS_TEMPLATE = False;

-- Once the database is created, you can use it to store the extracted data. For example, you can use the 
-- following SQL code to create a table named "customers" to store customer information:

--CREATE TABLE customers (
  --customer_id SERIAL PRIMARY KEY,
  --first_name VARCHAR(255) NOT NULL,
  --last_name VARCHAR(255) NOT NULL,
  --email VARCHAR(255) UNIQUE NOT NULL
--);

-- INSERT INTO customers (first_name, last_name, email)
-- VALUES ('John', 'Doe', 'johndoe@example.com');

-- Task 1: Cast the columns of the orders_table to the correct data types.
-- To change the data types in PostgreSQL (pgAdmin4) for the specified columns in the orders_table, 
-- it need to execute ALTER TABLE statements. However, determining the maximum length for VARCHAR columns 
-- requires knowledge of the actual data. Let's assume it want to set a reasonable maximum length, 
--such as 255 characters, for VARCHAR columns.

-- Here's an example SQL script that it can use to change the data types:

-- Alter date_uuid column
ALTER TABLE orders_table
ALTER COLUMN date_uuid TYPE UUID USING date_uuid::UUID;

-- Alter user_uuid column
ALTER TABLE orders_table
ALTER COLUMN user_uuid TYPE UUID USING user_uuid::UUID;

-- Alter card_number column (Assuming a max length of 255 for card_number)
ALTER TABLE orders_table
ALTER COLUMN card_number TYPE VARCHAR(255);

-- Alter store_code column (Assuming a max length of 255 for store_code)
ALTER TABLE orders_table
ALTER COLUMN store_code TYPE VARCHAR(255);

-- Alter product_code column (Assuming a max length of 255 for product_code)
ALTER TABLE orders_table
ALTER COLUMN product_code TYPE VARCHAR(255);

-- Alter product_quantity column
ALTER TABLE orders_table
ALTER COLUMN product_quantity TYPE SMALLINT;

-- Task 2: Cast the columns of the dim_users_table to the correct data types.
-- To cast the columns in PostgreSQL (pgAdmin4) for the specified columns in the local_dim_users, 
--it can use the ALTER TABLE statement. Here's an example SQL script:

-- Alter first_name column (Assuming a max length of 255 for first_name)
ALTER TABLE public.local_dim_users
ALTER COLUMN first_name TYPE VARCHAR(255);

-- Alter last_name column (Assuming a max length of 255 for last_name)
ALTER TABLE public.local_dim_users
ALTER COLUMN last_name TYPE VARCHAR(255);

-- Alter date_of_birth column
ALTER TABLE public.local_dim_users
ALTER COLUMN date_of_birth TYPE DATE USING date_of_birth::DATE;

-- Alter country_code column (Assuming a max length of 255 for country_code)
ALTER TABLE public.local_dim_users
ALTER COLUMN country_code TYPE VARCHAR(255);

-- Alter user_uuid column
ALTER TABLE public.local_dim_users
ALTER COLUMN user_uuid TYPE UUID USING user_uuid::UUID;

-- Alter join_date column
ALTER TABLE public.local_dim_users
ALTER COLUMN join_date TYPE DATE USING join_date::DATE;


-- Assuming the table is named dim_store_details
ALTER TABLE dim_store_details
ALTER COLUMN longitude TYPE DOUBLE PRECISION USING longitude::DOUBLE PRECISION;


UPDATE public.dim_store_details
SET longitude = NULL
WHERE longitude = 'N/A';
--or 
ALTER TABLE dim_store_details
ALTER COLUMN longitude TYPE FLOAT USING NULLIF(NULLIF(longitude, ' '), 'NULL')::FLOAT;

-- This query uses a regular expression (^\d+$) to identify rows 
-- where staff_numbers does not consist entirely of digits. 
UPDATE dim_store_details
SET staff_numbers = NULL
WHERE NOT staff_numbers ~ '^\d+$';

-- This query updates all rows where the latitude column has the value "NULL" 
-- and sets it to a proper NULL value.
UPDATE dim_store_details
SET latitude = NULL
WHERE latitude = 'NULL';

--  the ALTER TABLE statement to change the data type:
ALTER TABLE dim_store_details
  ALTER COLUMN longitude TYPE FLOAT,
  ALTER COLUMN locality TYPE VARCHAR(255),
  ALTER COLUMN store_code TYPE VARCHAR(255),
  ALTER COLUMN staff_numbers TYPE SMALLINT USING staff_numbers::SMALLINT,
  ALTER COLUMN opening_date TYPE DATE,
  ALTER COLUMN store_type TYPE VARCHAR(255),
  ALTER COLUMN latitude TYPE DOUBLE PRECISION USING latitude::DOUBLE PRECISION,
  ALTER COLUMN country_code TYPE VARCHAR(255), 
  ALTER COLUMN continent TYPE VARCHAR(255);

-- check the data type
SELECT index, address, longitude, locality, store_code, staff_numbers, opening_date, store_type, latitude, country_code, continent
	FROM public.dim_store_details
	ORDER BY index;

-- check the data null to N/A.
-- there is a row within the dim_store_details table that shows the location of the online store.
-- Within that table, it should be able to see a row where the store_type or store_code starts with WEB
-- When it find that row, it just need to make sure the non-relevant column for that row has the values N/A
-- For e.g the address column can be N/A since the store is on the web and there is no physical address for us to go to

SELECT *
FROM dim_store_details
WHERE store_type LIKE 'WEB%' OR store_code LIKE 'WEB%';

-- This query updates the address column to 'N/A' for the rows where either the store_type starts with 'WEB' 
-- or the store_code starts with 'WEB'.
UPDATE dim_store_details
SET address = 'N/A'
WHERE store_type LIKE 'WEB%' OR store_code LIKE 'WEB%';

-- Task 4: Make changes to the dim_products  table for the delivery team in pgAdmin SQL 
-- Remove £ character from product_price in PostgreSQL (pgAdmin4):
UPDATE dim_products
SET product_price = REPLACE(product_price, '£', '');

-- Add a new column weight_class:
-- To be on the safe side and accommodate potential future changes, 
-- it might choose a length slightly larger than the longest value.
-- Let's say 30 characters:
ALTER TABLE dim_products
ADD COLUMN weight_class VARCHAR(30);

-- This statement uses the CASE statement to categorise the weight_kg values into different classes and 
-- updates the weight_class column accordingly.
-- Update weight_class based on weight range:
UPDATE dim_products
SET weight_class = 
    CASE 
        WHEN weight_kg < 2 THEN 'Light'
        WHEN weight_kg >= 2 AND weight_kg < 40 THEN 'Mid_Sized'
        WHEN weight_kg >= 40 AND weight_kg < 140 THEN 'Heavy'
        WHEN weight_kg >= 140 THEN 'Truck_Required'
        ELSE NULL -- Handle any other cases, if necessary
    END;


-- check data
SELECT "Unnamed: 0", product_name, category, "EAN", date_added, uuid, removed, product_code, weight_kg, product_price_pound, weight_class
FROM public.dim_products
ORDER BY "Unnamed: 0";


-- Task 5: Update the dim_products  table with the required data types in pgAdmin SQL.

-- After all the columns are created and cleaned, change the data types of the products table.

-- It will want to rename the removed column to still_available before changing its data type.

-- Rename the 'removed' column to 'still_available'
ALTER TABLE dim_products RENAME COLUMN removed TO still_available;

-- To find the maximum length of the EAN column in the dim_products table in pgAdmin SQL, 
-- it can use the following query:
-- It can then use this result to set the appropriate length in the VARCHAR(?) declaration
-- when altering the column data type. -17
SELECT MAX(LENGTH("EAN")) AS max_length
FROM dim_products;

-- 11
SELECT MAX(LENGTH(product_code)) AS max_length
FROM dim_products;

-- 14
SELECT MAX(LENGTH(weight_class)) AS max_length
FROM dim_products;

-- Change data types of the columns
ALTER TABLE dim_products
  ALTER COLUMN product_price TYPE FLOAT USING NULLIF(product_price, '')::FLOAT,
  ALTER COLUMN weight TYPE FLOAT USING NULLIF(weight, '')::FLOAT,
  ALTER COLUMN EAN TYPE VARCHAR(30),
  ALTER COLUMN product_code TYPE VARCHAR(30),
  ALTER COLUMN date_added TYPE DATE,
  ALTER COLUMN uuid TYPE UUID USING NULLIF(uuid, '')::UUID,
  ALTER COLUMN still_available TYPE BOOL,
  ALTER COLUMN weight_class TYPE VARCHAR(30); 

SELECT COUNT(*)
FROM dim_products
WHERE weight_kg IS NULL;
-----------
-- Task 5: Update the dim_products table with the required data types.
-- After all the columns are created and cleaned, change the data types of the products table.

-- You will want to rename the removed column to still_available before changing its data type.

-- Make the changes to the columns to cast them to the following data types:

-- Clean data
UPDATE dim_products
SET 
  product_price_pound = CASE 
                          WHEN product_price_pound IS NULL OR trim(product_price_pound::text) ~ '^\s*$|^NA$' THEN NULL
                          ELSE product_price_pound::FLOAT
                        END,
  weight_kg = CASE
                WHEN weight_kg IS NULL OR trim(weight_kg::text) ~ '^\s*$|^NA$' THEN NULL
                ELSE weight_kg::FLOAT
              END;

-- Identify and handle invalid date values
-- some values like "CCAVRB79VV" etc cannot be cast automatically to a date. 
UPDATE dim_products
SET
  date_added = CASE 
                 WHEN date_added ~ '^\D*$' OR 
                      date_added ~ '^CCAVRB79VV$' OR
                      date_added ~ '^PEPWA0NCVH$' OR
                      date_added ~ '^09KREHTMWL$'  -- Add the new invalid value
                 THEN NULL
                 ELSE NULLIF(NULLIF(trim(date_added::text), ''), '')::DATE
               END;
-- check invalid date values
SELECT uuid
FROM dim_products
WHERE uuid !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$';

"7QB0Z9EW1G"
"VIBLHHVPMN"
"CP8XYQVGGU"

-- This query updates the uuid column to NULL for rows where the uuid matches any of the specified values in the IN list. 
-- Make sure to replace the UUID values in the list with the actual values you want to update.
--After running this query, you can check the rows again to verify that the specified UUIDs are set to NULL.
-- Here's an update the invalid UUID values to NULL:

UPDATE dim_products
SET uuid = NULL
WHERE uuid IN ('7QB0Z9EW1G', 'VIBLHHVPMN', 'CP8XYQVGGU');

-- Change data types
ALTER TABLE dim_products
  ALTER COLUMN product_price_pound TYPE FLOAT USING NULLIF(NULLIF(trim(product_price_pound::text), ''), 'NA')::FLOAT,
  ALTER COLUMN weight_kg TYPE FLOAT USING NULLIF(NULLIF(trim(weight_kg::text), ''), 'NA')::FLOAT,
  ALTER COLUMN "EAN" TYPE VARCHAR(30),
  ALTER COLUMN product_code TYPE VARCHAR(30),
  ALTER COLUMN date_added TYPE DATE USING NULLIF(NULLIF(trim(date_added::text), ''), '')::DATE,
  ALTER COLUMN uuid TYPE UUID USING NULLIF(uuid, 'NA')::UUID,
  ALTER COLUMN still_available TYPE BOOLEAN USING (trim(still_available::text) = 'true'),
  --ALTER COLUMN still_available TYPE BOOLEAN USING CASE 
                                                    --WHEN trim(still_available::text) ~* 'true' THEN true
                                                    --WHEN trim(still_available::text) ~* 'false' THEN false
                                                    --ELSE NULL
                                                  --END,
  ALTER COLUMN weight_class TYPE VARCHAR(30);

---
--Task 6: Update the dim_date_times table.

--Now update the date table with the correct types:

SELECT "timestamp", month, year, day, time_period, date_uuid
	FROM public.dim_date_times;
	
-- Update month column
ALTER TABLE dim_date_times
ALTER COLUMN month TYPE VARCHAR(50);

-- Update year column
ALTER TABLE dim_date_times
ALTER COLUMN year TYPE VARCHAR(50);

-- Update day column
ALTER TABLE dim_date_times
ALTER COLUMN day TYPE VARCHAR(50);

-- Update time_period column
ALTER TABLE dim_date_times
ALTER COLUMN time_period TYPE VARCHAR(50);

-- Update date_uuid column to UUID type
ALTER TABLE dim_date_times
ALTER COLUMN date_uuid TYPE UUID USING (date_uuid::UUID);

-- Task 7: Updating the dim_card_details table.
-- Now it need to update the last table for the card details.

--Make the associated changes after finding out what the lengths of each variable should be:
-- check data
SELECT card_number, expiry_date, card_provider, date_payment_confirmed
	FROM public.dim_card_details;

-- To find the maximum length of the card_number column in the public.dim_card_details table in pgAdmin SQL, 
-- it can use the following query:
-- It can then use this result to set the appropriate length in the VARCHAR(?) declaration
-- when altering the column data type. -22
SELECT MAX(LENGTH(card_number)) AS max_length
FROM public.dim_card_details;
-- 22

SELECT MAX(LENGTH(expiry_date)) AS max_length
FROM public.dim_card_details;
-10

-- Update data type for card_number to VARCHAR(30)
ALTER TABLE dim_card_details
ALTER COLUMN card_number TYPE VARCHAR(30);

-- Update data type for expiry_date to VARCHAR(16)
ALTER TABLE dim_card_details
ALTER COLUMN expiry_date TYPE VARCHAR(16);

-- Update data type for date_payment_confirmed to DATE
-- Convert the existing data to DATE using the specified format
ALTER TABLE dim_card_details
ALTER COLUMN date_payment_confirmed TYPE DATE
USING (
  CASE 
    WHEN date_payment_confirmed IS NOT NULL 
         AND date_payment_confirmed ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' -- Check for valid date format
    THEN to_date(date_payment_confirmed, 'YYYY-MM-DD')
    ELSE '1900-01-01'::DATE  -- Replace with a default date or another appropriate representation
  END
);

-- Task 8: Create the primary keys in the dimension tables.
-- Now that the tables have the appropriate data types we can begin adding the primary keys to each of the tables prefixed with dim.

-- Each table will serve the orders_table which will be the single source of truth for our orders.

-- Check the column header of the orders_table you will see all but one of the columns exist in one of our tables prefixed with dim.

-- We need to update the columns in the dim tables with a primary key that matches the same column in the orders_table.

-- Using SQL, update the respective columns as primary key columns.

-- check data
SELECT level_0, index, date_uuid, user_uuid, card_number, store_code, product_code, product_quantity
	FROM public.orders_table;

-- Get table name
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
"dim_date_times"
"dim_products"
"local_dim_users"
"dim_card_details"
"dim_store_details"
"orders_table"

-- Identify NULL Values:
-- check for both actual NULL values and rows where the card_number column contains the string 'NULL': 
SELECT *
FROM public.dim_card_details
WHERE card_number IS NULL OR card_number = 'NULL';

--remove rows where card_number is set to the string 'NULL', 
-- it can use the DELETE statement with the same condition in the WHERE clause.
DELETE FROM public.dim_card_details
WHERE card_number = 'NULL';

-- Identify NULL Values:
-- check for both actual NULL values and rows where the card_number column contains the string 'NULL': 

SELECT *
FROM public.dim_store_details
WHERE store_code IS NULL OR store_code = 'NULL';

--index
--405
--217
--437

-- delete specific rows based on the result SELECT query, 
-- it can use the DELETE statement with a WHERE clause. Here's the SQL

DELETE FROM public.dim_store_details
WHERE store_code IS NULL OR store_code = 'NULL';

-- Identify NULL Values:
-- check for both actual NULL values and rows where the card_number column contains the string 'NULL': 
SELECT *
FROM public.dim_products
WHERE product_code IS NULL OR product_code = 'NULL';
-- Unnamed:0
--266
--788
--794
--1660

--remove rows where product_code is set to the string 'NULL', 
-- it can use the DELETE statement with the same condition in the WHERE clause.
DELETE FROM public.dim_products
WHERE product_code IS NULL OR product_code = 'NULL';


-- Set the Primary Keys:
-- Primary keys for the five columns that match the five dimension
-- Assuming order_id is the primary key in the orders_table
-- Update dim_date_table with primary key
ALTER TABLE public.dim_date_times
ADD PRIMARY KEY (date_uuid);

-- Update dim_user_table with primary key
ALTER TABLE public.local_dim_users
ADD PRIMARY KEY (user_uuid);

-- Update dim_card_table with primary key
ALTER TABLE public.dim_card_details
ADD PRIMARY KEY (card_number);

-- Update dim_store_table with primary key
ALTER TABLE public.dim_store_details
ADD PRIMARY KEY (store_code);

-- Update dim_product_table with primary key
ALTER TABLE public.dim_products
ADD PRIMARY KEY (product_code);

-- Check the primary keys in the tables, it can query the information schema. 
-- Here's a query that you can use to check the primary key constraints on the specified tables:
-- see data-primary-keys.csv

SELECT
    conname AS constraint_name,
    conrelid::regclass AS table_name,
    a.attname AS column_name
FROM
    pg_constraint c
JOIN
    pg_attribute a ON a.attnum = ANY(c.conkey)
WHERE
    confrelid = 0
    AND conrelid::regclass::text IN ('dim_date_times', 'local_dim_users', 'dim_card_details', 'dim_store_details', 'dim_products');

SELECT
    table_name,
    column_name
FROM
    information_schema.key_column_usage
WHERE
    constraint_name LIKE '%_pkey'
    AND table_name IN ('dim_date_times', 'local_dim_users', 'dim_card_details', 'dim_store_details', 'dim_products');

--
--table_name        column_name
--"local_dim_users"	"user_uuid"
--"dim_card_details"	"card_number"
--"dim_store_details"	"store_code"
--"dim_date_times"	"date_uuid"
--"dim_products"	"product_code"
--
--Task 9: Finalising the star-based schema & adding the foreign keys to the orders table.
--With the primary keys created in the tables prefixed with dim it can now create the foreign keys 
--in the orders_table to reference the primary keys in the other tables.
--Use SQL to create those foreign key constraints that reference the primary keys of the other table.
--This makes the star-based database schema complete.

UPDATE dim_card_details
SET card_number = REPLACE(card_number, '?', '')
WHERE card_number LIKE '%69242%';

UPDATE public.orders_table
SET card_number = CASE
    WHEN card_number LIKE '?%' THEN SUBSTRING(card_number FROM 2)
    ELSE card_number
END;

UPDATE public.dim_card_details
SET card_number = REPLACE(card_number, '?', '')
WHERE card_number LIKE '%69242%';

SELECT card_number
FROM public.dim_card_details
WHERE card_number LIKE '?%'
--LIMIT 30;  -- Adjust the limit as needed to inspect a manageable number of rows

"?4971858637664481"
"???3554954842403828"
"??4654492346226715"
"?3544855866042397"
"??2720312980409662"
"??4982246481860"
"?213174667750869"
"????3505784569448924"
"????3556268655280464"
"???2604762576985106"
"???5451311230288361"
"???4252720361802860591"
"?4217347542710"
"?584541931351"
"???4672685148732305"
"??3535182016456604"
"????3512756643215215"
"?2314734659486501"
"????341935091733787"
"????3543745641013832"
"??575421945446"
"??630466795154"
"????38922600092697"
"????344132437598598"
"???4814644393449676"

UPDATE public.dim_card_details
SET card_number = REPLACE(card_number, '?', '')
WHERE card_number LIKE '%?%';

-- Add foreign key to dim_date_times
ALTER TABLE public.orders_table
ADD CONSTRAINT fk_orders_date_uuid
FOREIGN KEY (date_uuid)
REFERENCES public.dim_date_times(date_uuid);

-- Add foreign key to local_dim_users
ALTER TABLE public.orders_table
ADD CONSTRAINT fk_orders_user_uuid
FOREIGN KEY (user_uuid)
REFERENCES public.local_dim_users(user_uuid);

-- Add foreign key to dim_card_details
ALTER TABLE public.orders_table
ADD CONSTRAINT fk_orders_card_number
FOREIGN KEY (card_number)
REFERENCES public.dim_card_details(card_number);

-- Add foreign key to dim_store_details
ALTER TABLE public.orders_table
ADD CONSTRAINT fk_orders_store_code
FOREIGN KEY (store_code)
REFERENCES public.dim_store_details(store_code);

-- Add foreign key to dim_products
ALTER TABLE public.orders_table
ADD CONSTRAINT fk_orders_product_code
FOREIGN KEY (product_code)
REFERENCES public.dim_products(product_code);
