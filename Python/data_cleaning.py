import pandas as pd

class DataCleaning:
    def __init__(self):
        pass

    def clean_card_data(self, card_data):
        # Method to clean card data (remove erroneous values, NULL values, formatting errors, etc.)
        # Implement your cleaning logic here
        cleaned_data = card_data  # Placeholder, replace with actual cleaning logic
        return cleaned_data

    def clean_user_data(self, data):
        # Method to clean user data
        # Check for NULL values
        data = data.dropna()

        # Validate dates
        ## data['date_of_birth'] = pd.to_datetime(data['date_of_birth'])
        #data['date_of_birth'] = pd.to_datetime(data['date_of_birth'], format='%Y-%m-%d %B')
        data['date_of_birth'] = pd.to_datetime(data['date_of_birth'], format='mixed', errors='coerce')

        # Check for incorrectly typed values
        data['country'] = data['country'].apply(lambda x: x.upper())

        # Remove rows with incorrect information
        data = data[data['country'] != 'INVALID']

        return data
    
    def clean_store_data(self, stores_df):
        # Implement your cleaning logic here
        # For example, remove null values, handle data type conversions, etc.
        cleaned_stores_df = stores_df.dropna()

        # Remove 'ee' prefix from 'continent'
        cleaned_stores_df['continent'] = cleaned_stores_df['continent'].str.replace('ee', '', regex=False)

        # Handle formatting issues in 'opening_date'
        cleaned_stores_df['opening_date'] = pd.to_datetime(cleaned_stores_df['opening_date'], errors='coerce')

        return cleaned_stores_df




