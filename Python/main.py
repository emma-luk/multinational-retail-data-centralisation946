from data_extraction import DataExtractor
from database_utils import DatabaseConnector
from data_cleaning import DataCleaning
# Extract data from RDS database
data_extractor = DataExtractor()
db_connector = DatabaseConnector()
sourceDB = db_connector.init_db_engine()

# Get legacy users table name
table_name = 'legacy_users'

# Extract legacy users data
legacy_users_data = data_extractor.read_rds_table(table_name, sourceDB)

# Print legacy users data
print(legacy_users_data)

# Extract data from RDS database
data_extractor = DataExtractor()
db_connector = DatabaseConnector()
table_name = 'user_data'
user_data = data_extractor.extract_data_from_rds(db_connector, table_name)

# Clean user data
data_cleaning = DataCleaning()
cleaned_user_data = data_cleaning.clean_user_data(user_data)

# Upload cleaned data to database
db_connector.upload_to_db(cleaned_user_data, 'dim_users', 'sales_data')