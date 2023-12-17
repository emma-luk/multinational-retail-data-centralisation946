# main.py
from data_extraction import DataExtractor
from database_utils import DatabaseConnector
from data_cleaning import DataCleaning
import yaml

# Connection to AWS RDS database
db = DatabaseConnector("D:\development\projects\multinational-retail-data-centralisation946\Python\db_creds.yaml")
# Connection to my local database
db2 = DatabaseConnector("D:\development\projects\multinational-retail-data-centralisation946\Python\local_credentials.yaml")

api_key = 'yFBQbwXe9J3sd6zWVAMrK6lcxxr0q1lr2PT6DDMX'
data_extractor = DataExtractor(api_key=api_key)
data_cleaning = DataCleaning()

# Task 3: Extract and clean the user data
db.list_db_tables()

table_name = 'legacy_users'
# Extract Data
legacy_users_data = data_extractor.read_rds_table(table_name, db.engine)
# Transform Data
cleaned_user_data = data_cleaning.clean_user_data(legacy_users_data)
# Load Data
db2.upload_to_db(cleaned_user_data, 'local_dim_users', db2.engine)

# Task 4: Extracting users and cleaning card details
pdf_url = 'https://data-handling-public.s3.eu-west-1.amazonaws.com/card_details.pdf'

# Extract
pdf_data = data_extractor.retrieve_pdf_data_from_s3(pdf_url)

# Transform
cleaned_pdf_data = data_cleaning.clean_card_data(pdf_data)

# Load
db2.upload_to_db(cleaned_pdf_data, 'dim_card_details', db2.engine)


# Task 5: Extract and clean the details of each store

# Extract
store_data = data_extractor.extract_all_stores("https://aqj7u5id95.execute-api.eu-west-1.amazonaws.com/prod/number_stores", "https://aqj7u5id95.execute-api.eu-west-1.amazonaws.com/prod/store_details", {"x-api-key": "yFBQbwXe9J3sd6zWVAMrK6lcxxr0q1lr2PT6DDMX"})
# Transform
cleaned_store_data = data_cleaning.clean_store_data(store_data)
# Load
db2.upload_to_db(cleaned_store_data, 'dim_store_details', db2.engine)

# Task 6: Extract and clean the product details

s3_address_products = 's3://data-handling-public/products.csv'
products_data = data_extractor.extract_from_s3(s3_address_products)

# Extract
converted_products_data = data_cleaning.convert_product_weights(products_data)
# Transform
cleaned_products_data = data_cleaning.clean_products_data(converted_products_data)
# Load
db2.upload_to_db(cleaned_products_data, 'dim_products', db2.engine)

# Task 7: Retrieve and clean the orders table

# Step 1: List all tables in the database
all_tables = db.list_db_tables()
# Print the list of tables
# All Tables: ['legacy_store_details', 'legacy_users', 'orders_table']
print("All Tables:", all_tables)

# Extract
# Step 2: Extract the orders data
orders_table_name = 'orders_table'  # Use the correct name of your orders table
orders_data = data_extractor.read_rds_table(orders_table_name, db.engine)

# Transform
# Step 3: Clean the orders data
cleaned_orders_data = data_cleaning.clean_orders_data(orders_data)

# Load
# Step 4: Upload cleaned orders data to the same 'orders_table'
db2.upload_to_db(cleaned_orders_data, orders_table_name)

# Task 8: Retrieve and clean the date events data

# Extract data from the S3 link
s3_address_date_events = 'https://data-handling-public.s3.eu-west-1.amazonaws.com/date_details.json'
date_events_data = data_extractor.extract_from_s3(s3_address_date_events)

# Check if data extraction was successful
if date_events_data is not None:
    # Transform (clean) the date events data
    cleaned_date_events_data = data_cleaning.clean_date_events_data(date_events_data)

    # Load cleaned date events data to the database
    db2.upload_to_db(cleaned_date_events_data, 'dim_date_times')

    print("Date events data extracted, cleaned, and loaded to dim_date_times table.")
else:
    print("Error extracting date events data from S3.")
