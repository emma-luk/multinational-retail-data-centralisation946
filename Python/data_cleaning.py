import pandas as pd
from pandasgui import show

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
        # cleaned_stores_df = stores_df.dropna()
        cleaned_stores_df = stores_df
        # Remove 'ee' prefix from 'continent'
        cleaned_stores_df['continent'] = cleaned_stores_df['continent'].str.replace('ee', '', regex=False)
        print(cleaned_stores_df["continent"].unique())
        # Handle formatting issues in 'opening_date'
        cleaned_stores_df['opening_date'] = pd.to_datetime(cleaned_stores_df['opening_date'], errors='coerce')

        return cleaned_stores_df

if __name__ == "__main__":
    data_clean_obj = DataCleaning()
    df = pd.read_csv("all_store_data.csv")
    cleaned_store_data = data_clean_obj.clean_store_data(df)
    cleaned_store_data.drop(columns="index", inplace=True)
    print(cleaned_store_data.columns)
    show(cleaned_store_data)
    


