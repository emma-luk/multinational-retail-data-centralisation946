from data_extraction import DataExtractor
from database_utils import DatabaseConnector

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
