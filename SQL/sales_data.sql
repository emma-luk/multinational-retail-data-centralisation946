-- Initialise a new database locally to store the extracted data.
-- Set up a new database within pgadmin4 and name it sales_data.
-- This database will store all the company information once you extract it for the various data sources.

-- This code will create a new database named "sales_data" in the current PostgreSQL instance. If you are using pgAdmin4, you can also create the database by following these steps:

-- Open pgAdmin4 and connect to your PostgreSQL server.
-- Right-click on the "Databases" node and select "Create".
-- In the "Create database" dialog box, enter "sales_data" as the name of the database.
-- Click "OK" to create the database.

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




ERROR:  invalid input syntax for type uuid: "W43MSCMQ88" 

SQL state: 22P02













-- Alter first_name column (Assuming a max length of 255 for first_name)
ALTER TABLE local_dim_users
ALTER COLUMN first_name TYPE VARCHAR(255);

-- Alter last_name column (Assuming a max length of 255 for last_name)
ALTER TABLE local_dim_users
ALTER COLUMN last_name TYPE VARCHAR(255);

-- Alter date_of_birth column
ALTER TABLE local_dim_users
ALTER COLUMN date_of_birth TYPE DATE USING date_of_birth::DATE;

-- Alter country_code column (Assuming a max length of 255 for country_code)
ALTER TABLE local_dim_users
ALTER COLUMN country_code TYPE VARCHAR(255);

-- Alter user_uuid column
ALTER TABLE local_dim_users
ALTER COLUMN user_uuid TYPE UUID USING user_uuid::UUID;

-- Alter join_date column
ALTER TABLE local_dim_users
ALTER COLUMN join_date TYPE DATE USING join_date::DATE;

SELECT index, first_name, last_name, date_of_birth, company, email_address, address, country, country_code, phone_number, join_date, user_uuid
	FROM public.local_dim_users;