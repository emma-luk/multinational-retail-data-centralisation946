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


# Task 7: ....

# Extract

# Transform

# Load


# Example: Retrieve a specific store
#store_number = '123'
#store_data = data_extractor.retrieve_store_data(store_number)

# Example: Get the number of stores
#number_of_stores = data_extractor.get_number_of_stores()

# Retrieve store data using the API
#store_data = data_extractor.retrieve_stores_data(store_endpoint, headers)

# Step 1: List tables and find the orders table
tables = db.list_db_tables()
order_table_name = None
for table in tables:
    if "order" in table.lower():
        order_table_name = table
        break

# Step 2: Extract orders data
if order_table_name:
    orders_data = data_extractor.extract_data_from_rds(order_table_name, db.engine)
    print("Orders data extracted successfully.")
    print(orders_data.head())
else:
    print("Orders table not found.")

# Step 3: Clean orders data
if order_table_name:
    data_clean_obj = DataCleaning()  # Create an instance of DataCleaning
    cleaned_orders_data = data_clean_obj.clean_orders_data(orders_data)
    print("Orders data cleaned successfully.")
    print(cleaned_orders_data.head())

    # Step 4: Upload cleaned orders data to the database
    db.upload_to_db(cleaned_orders_data, 'orders_table')
    print("Cleaned orders data uploaded to the database.")
else:
    print("Orders table not found.")
