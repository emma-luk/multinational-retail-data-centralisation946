# main.py
from data_extraction import DataExtractor
from database_utils import DatabaseConnector
from data_cleaning import DataCleaning
import yaml
from database_utils import DatabaseConnector

# Extract data from RDS database
data_extractor = DataExtractor()
db_connector = DatabaseConnector()
engine = db_connector.init_db_engine()

# Get legacy users table name
table_name = 'legacy_users'

# Extract legacy users data
legacy_users_data = data_extractor.extract_data_from_rds(table_name)

# Print legacy users data
print(legacy_users_data)

# Clean user data
data_cleaning = DataCleaning()
cleaned_user_data = data_cleaning.clean_user_data(legacy_users_data)

# Upload cleaned data to database
db_connector.upload_to_db(cleaned_user_data, 'dim_users', engine=engine)  # Explicitly pass the engine object

# Read database credentials from credentials.yaml
db_creds = DatabaseConnector.read_db_creds('credentials.yaml')

# Initialize the database engine using the credentials from the alternative file
engine = DatabaseConnector.init_db_engine(db_creds)

# Perform data extraction, transformation, and loading (ETL) operations

