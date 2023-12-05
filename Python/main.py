# main.py
from data_extraction import DataExtractor
from database_utils import DatabaseConnector
from data_cleaning import DataCleaning
import yaml

# Initialize RDS engine using credentials from db_creds.yaml
db_rds = DatabaseConnector()
rds_creds = db_rds.read_db_creds('db_creds.yaml')  # Explicitly pass the filename
rds_engine = DatabaseConnector.init_db_engine(rds_creds)

# Initialize local database engine using credentials from local_credentials.yaml
db_local = DatabaseConnector()
local_creds = db_local.read_db_creds('local_credentials.yaml')  # Explicitly pass the filename
local_engine = DatabaseConnector.init_db_engine(local_creds)

# Extract data from RDS database using RDS engine
data_extractor = DataExtractor()
table_name = 'legacy_users'
legacy_users_data = data_extractor.extract_data_from_rds(table_name, rds_engine)

# Clean user data
data_cleaning = DataCleaning()
cleaned_user_data = data_cleaning.clean_user_data(legacy_users_data)

# Upload cleaned data to local database using local engine
db_connector = DatabaseConnector()
db_connector.upload_to_db(cleaned_user_data, 'local_dim_users', engine=local_engine)
