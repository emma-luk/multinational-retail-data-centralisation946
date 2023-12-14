# main.py
from data_extraction import DataExtractor
from database_utils import DatabaseConnector
from data_cleaning import DataCleaning
import yaml

# Initialize RDS engine using credentials from db_creds.yaml
# db_rds = DatabaseConnector()
db = DatabaseConnector ("D:\development\projects\multinational-retail-data-centralisation946\Python\db_creds.yaml")
db.list_db_tables()
db2 = DatabaseConnector("D:\development\projects\multinational-retail-data-centralisation946\Python\local_credentials.yaml")

# Initialize local database engine using credentials from local_credentials.yaml
#db_local = DatabaseConnector()
#local_creds = db_local.read_db_creds('local_credentials.yaml')  # Explicitly pass the filename
#local_engine = DatabaseConnector.init_db_engine(local_creds)

# Extract data from RDS database using RDS engine
# data_extractor = DataExtractor(api_key='api_key') ## 

# Initialize DataExtractor with the API key
api_key = 'yFBQbwXe9J3sd6zWVAMrK6lcxxr0q1lr2PT6DDMX'
data_extractor = DataExtractor(api_key=api_key)

table_name = 'legacy_users'
legacy_users_data = data_extractor.read_rds_table(table_name, db.engine)

# Clean user data
data_cleaning = DataCleaning()
cleaned_user_data = data_cleaning.clean_user_data(legacy_users_data)

# Upload cleaned data to local database using local engine
#db2.upload_to_db(cleaned_user_data, 'local_dim_users', db2.engine)
db_sales_data = DatabaseConnector("D:\development\projects\multinational-retail-data-centralisation946\Python\local_credentials.yaml")


'''
DataExtractor with the API key
'''



# Example: Retrieve a specific store
#store_number = '123'
#store_data = data_extractor.retrieve_store_data(store_number)

# Example: Get the number of stores
#number_of_stores = data_extractor.get_number_of_stores()

# Retrieve store data using the API
#store_data = data_extractor.retrieve_stores_data(store_endpoint, headers)

# Clean store data
data_cleaning = DataCleaning()

# Upload cleaned store data to the database using local engine

store_data = data_extractor.extract_all_stores("https://aqj7u5id95.execute-api.eu-west-1.amazonaws.com/prod/number_stores", "https://aqj7u5id95.execute-api.eu-west-1.amazonaws.com/prod/store_details", {"x-api-key": "yFBQbwXe9J3sd6zWVAMrK6lcxxr0q1lr2PT6DDMX"})
cleaned_store_data = data_cleaning.clean_store_data(store_data)
db2.upload_to_db(cleaned_store_data, 'dim_store_details', db2.engine)


# Example: Extract data from S3
s3_address_products = 's3://data-handling-public/products.csv'
products_data = data_extractor.extract_from_s3(s3_address_products)

# Example: Convert product weights
data_cleaning = DataCleaning()
converted_products_data = data_cleaning.convert_product_weights(products_data)

# Example: Clean products data
cleaned_products_data = data_cleaning.clean_products_data(converted_products_data)

# Example: Upload to database
# db.upload_products_to_db(cleaned_products_data, products_data, db2.engine)
db_sales_data = DatabaseConnector("D:\development\projects\multinational-retail-data-centralisation946\Python\db_creds_sales_data.yaml")
db_sales_data.upload_to_db(cleaned_products_data, 'dim_products', db_sales_data.engine)