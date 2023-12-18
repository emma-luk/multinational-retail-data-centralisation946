# data_extraction.py
import tabula
import pandas as pd
import requests
import boto3
from io import BytesIO
from database_utils import DatabaseConnector
from data_cleaning import DataCleaning
from botocore.exceptions import NoCredentialsError
from urllib.parse import urlparse

class DataExtractor:
    def __init__(self, api_key):
        self.api_key = api_key
        self.store_data_list = []  # List to hold store data

    def read_rds_table(self, table_name, engine):
        dataframe = pd.read_sql_table(table_name, engine)
        return dataframe

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

            # Check if the data is a dictionary and contains necessary information
            if isinstance(stores_data, dict) and 'index' in stores_data and 'address' in stores_data:
                stores_df = pd.DataFrame([stores_data])  # Convert single dictionary to DataFrame

                # Append the DataFrame to the list
                self.store_data_list.append(stores_df)

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
    
    # TODO implement this loop through all stores and extract the data to a DataFrame
    def extract_all_stores(self, number_stores_endpoint, store_details_endpoint, headers):
        num_stores = self.list_number_of_stores(number_stores_endpoint, headers)
        
        if num_stores is not None:
            # List to hold all store data
            all_store_data_list = []

            # Loop through store numbers and retrieve store data
            for store_number in range(num_stores):
                # Call retrieve_stores_data method
                store_data = self.retrieve_stores_data(f"{store_details_endpoint}/{store_number}", headers)

                if store_data is not None:
                    # Append each store's data to the list
                    all_store_data_list.append(store_data)
                else:
                    print(f"Error retrieving store data for Store {store_number}.")

            # Combine all data frames into a single data frame
            all_store_data_df = pd.concat(all_store_data_list, ignore_index=True)

            # Display the first few rows of the combined data frame
            print("\nCombined Store Data:")
            print(all_store_data_df.head())

            # Export the combined data frame to a CSV file
            csv_filename = 'all_store_data.csv'
            all_store_data_df.to_csv(csv_filename, index=False)
            print(f"\nCombined Store Data exported to {csv_filename}")
            return all_store_data_df
        else:
            print("Error: Number of stores is None.")

    def get_store_data_list(self):
        return self.store_data_list
  
    def extract_from_s3(self, s3_address):
        try:
            print(f"Downloading file from {s3_address}...")
            # Initialize the S3 client
            s3 = boto3.client('s3')

            # Parse the S3 address to get the bucket and key
            parsed_url = urlparse(s3_address)
            bucket = parsed_url.netloc
            key = parsed_url.path.lstrip('/')

            # Download the file from S3
            response = s3.get_object(Bucket=bucket, Key=key)
            content = response['Body'].read()

            # Write the content to a file
            with open('date_details.json', 'wb') as file:
                file.write(content)

            print("File downloaded successfully.")
            print("Reading JSON file into DataFrame...")
            # Read the JSON file into a DataFrame
            df = pd.read_json('date_details.json')
            print("DataFrame created successfully.")
            return df

        except NoCredentialsError:
            print('Credentials not available')
            return None

# Example usage
# move to # main.py
# Example usage for API
if __name__ == "__main__":
    api_key = 'yFBQbwXe9J3sd6zWVAMrK6lcxxr0q1lr2PT6DDMX'
    number_of_stores_endpoint = 'https://aqj7u5id95.execute-api.eu-west-1.amazonaws.com/prod/number_stores'
    retrieve_store_endpoint = 'https://aqj7u5id95.execute-api.eu-west-1.amazonaws.com/prod/store_details/{}'
    
    headers = {'x-api-key': api_key}

    data_extractor = DataExtractor(api_key)
    data_extractor.extract_all_stores(number_of_stores_endpoint, retrieve_store_endpoint, headers)

    #print(f"API Key: {api_key}")
    #print(f"Number of Stores Endpoint: {number_of_stores_endpoint}")
    #print(f"Headers: {headers}")
