from data_extraction import DataExtractor
from database_utils import DatabaseConnector
from data_cleaning import DataCleaning

# Extract data from RDS database
data_extractor = DataExtractor()
db_connector = DatabaseConnector()
sourceDB = db_connector.init_db_engine()
sourceList = db_connector.list_db_tables() #  list_db_tables 
table_name = 'legacy_users'

user_data = data_extractor.extract_data_from_rds(db_connector, table_name)
# user_data = data_extractor.read_rds_table(table_name, sourceDB)

# Clean user data
#data_cleaning = DataCleaning()
#cleaned_user_data = data_cleaning.clean_user_data(user_data)

# Upload cleaned data to database
#db_connector.upload_to_db(cleaned_user_data, 'dim_users')
