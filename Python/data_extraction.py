import tabula
import pandas as pd
import boto3
from io import BytesIO
from database_utils import DatabaseConnector

class DataExtractor:
    def __init__(self):
        pass

    def retrieve_pdf_data_from_s3(self, bucket_name, pdf_key):
        # Method to extract data from a PDF document stored in an AWS S3 bucket
        try:
            s3 = boto3.client('s3')
            response = s3.get_object(Bucket=bucket_name, Key=pdf_key)
            pdf_data = response['Body'].read()

            # Use BytesIO to convert the byte content to a file-like object for tabula
            pdf_file = BytesIO(pdf_data)

            # Read PDF tables using tabula
            pdf_tables = tabula.read_pdf(pdf_file, pages='all', multiple_tables=True)
            
            # Concatenate tables into a single DataFrame
            combined_df = pd.concat(pdf_tables, ignore_index=True)
            return combined_df

        except Exception as e:
            print(f"Error extracting data from PDF: {e}")
            return None
        
    def list_number_of_stores(self, number_of_stores_endpoint, headers):
        # Method to retrieve the number of stores from the API
        pass

    def retrieve_stores_data(self, store_endpoint, headers):
        # Method to retrieve store details from the API and save them in a pandas DataFrame
        pass

    def extract_data_from_rds(self, table_name, engine):
        # Method to extract data from RDS database
        #db_connector = DatabaseConnector()
        #engine = db_connector.init_db_engine()
        data = self.read_rds_table(table_name, engine)
        return data

    def extract_data_from_csv(self, file_path):
        # Method to extract data from CSV file
        pass

    def extract_data_from_api(self, api_url, api_key):
        # Method to extract data from API
        pass

    def extract_data_from_s3_bucket(self, bucket_name, file_key):
        # Method to extract data from S3 bucket
        pass

    def read_rds_table(self, table_name, engine):
        data = pd.read_sql_table(table_name, engine)
        return data
    
# Example usage
if __name__ == "__main__":
    s3_bucket_name = 'your-s3-bucket-name'
    pdf_key = 'path/to/your/pdf/document.pdf'

    data_extractor = DataExtractor()
    pdf_data = data_extractor.retrieve_pdf_data_from_s3(s3_bucket_name, pdf_key)

    if pdf_data is not None:
        print(pdf_data.head())  # Display the first few rows of the extracted data

