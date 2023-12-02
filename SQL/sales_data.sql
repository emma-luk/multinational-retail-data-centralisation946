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

CREATE TABLE customers (
  customer_id SERIAL PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL
);


-- INSERT INTO customers (first_name, last_name, email)
-- VALUES ('John', 'Doe', 'johndoe@example.com');
