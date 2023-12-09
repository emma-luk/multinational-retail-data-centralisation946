import tabula
import pandas as pd
import requests
import boto3
from io import BytesIO
from database_utils import DatabaseConnector

class DataExtractor:
    def __init__(self, api_key):
        self.api_key = api_key

    def retrieve_pdf_data_from_s3(self, pdf_url):
        try:
            # Download the PDF content from the provided URL
            response = requests.get(pdf_url)
            pdf_data = response.content

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
        try:
            response = requests.get(number_of_stores_endpoint, headers=headers)
            response_data = response.json()

            # Print the full API response for debugging
            print("API Response:", response_data)

            number_of_stores = response_data.get('number_stores')  # Change 'count' to 'number_stores'
            if number_of_stores is not None:
                return number_of_stores
            else:
                print(f"Error: 'number_stores' key not found in API response.")
                return None

        except Exception as e:
            print(f"Error listing number of stores: {e}")
            return None

    def retrieve_stores_data(self, store_endpoint, headers):
        try:
            response = requests.get(store_endpoint, headers=headers)
            stores_data = response.json()

            # Print the full API response for debugging
            print("API Response for store data:", stores_data)

            # Check if the data is a list and has at least one item
            if isinstance(stores_data, list) and stores_data:
                stores_df = pd.DataFrame(stores_data)
                return stores_df
            elif isinstance(stores_data, dict) and 'error' in stores_data:
                print(f"Error in API response: {stores_data['error']}")
                return None
            else:
                print("Error: Invalid data format received from the API.")
                return None

        except Exception as e:
            print(f"Error retrieving stores data: {e}")
            return None

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
    
# Example usage for PDF
"""
if __name__ == "__main__":
    pdf_url = 'https://data-handling-public.s3.eu-west-1.amazonaws.com/card_details.pdf'

    data_extractor = DataExtractor()
    pdf_data = data_extractor.retrieve_pdf_data_from_s3(pdf_url)

    if pdf_data is not None:
        print(pdf_data.head())  # Display the first few rows of the extracted data

"""

# Example usage

# Example usage
if __name__ == "__main__":
    api_key = 'yFBQbwXe9J3sd6zWVAMrK6lcxxr0q1lr2PT6DDMX'
    number_of_stores_endpoint = 'https://aqj7u5id95.execute-api.eu-west-1.amazonaws.com/prod/number_stores'
    retrieve_store_endpoint = 'https://aqj7u5id95.execute-api.eu-west-1.amazonaws.com/prod/store_details/{}'
    
    headers = {'x-api-key': api_key}

    data_extractor = DataExtractor(api_key)
    number_of_stores = data_extractor.list_number_of_stores(number_of_stores_endpoint, headers)

    print(f"API Key: {api_key}")
    print(f"Number of Stores Endpoint: {number_of_stores_endpoint}")
    print(f"Headers: {headers}")

    if number_of_stores is not None:
        print(f"Number of stores to extract: {number_of_stores}")

        # Loop through store numbers and retrieve store data
        for store_number in range(1, number_of_stores + 1):
            # Call retrieve_stores_data method
            store_data = data_extractor.retrieve_stores_data(retrieve_store_endpoint.format(store_number), headers)

            if store_data is not None:
                print(f"Store Data for Store {store_number}:")
                print(store_data.head())  # Display the first few rows of the retrieved store data
            else:
                print(f"Error retrieving store data for Store {store_number}.")


"""
# Example usage
if __name__ == "__main__":
    api_key = 'yFBQbwXe9J3sd6zWVAMrK6lcxxr0q1lr2PT6DDMX'
    retrieve_store_endpoint = 'https://aqj7u5id95.execute-api.eu-west-1.amazonaws.com/prod/store_details/{}'
    headers = {'x-api-key': api_key}

    # Assuming you have a store number, replace '123' with the actual store number you want to retrieve
    store_number = '451'

    # Create an instance of DataExtractor
    data_extractor = DataExtractor(api_key)

    # Call retrieve_stores_data method
    store_data = data_extractor.retrieve_stores_data(retrieve_store_endpoint.format(store_number), headers)

    if store_data is not None:
        print(store_data.head())  # Display the first few rows of the retrieved store data
    else:
        print("Error retrieving store data.")
"""