#data_cleaning.py
import pandas as pd
from pandasgui import show

class DataCleaning:
    def __init__(self):
        pass

    def convert_product_weights(self, products_df):
        # Convert the 'weight' column to kilograms
        weights_in_kg = []

        for weight_str in products_df['weight']:
            # Check if the value is already a number (float or int)
            if pd.api.types.is_numeric_dtype(weight_str):
                weight_in_kg = float(weight_str)
            else:
                # Replace 'kg' and 'g' with an empty string
                weight_str = str(weight_str).replace('kg', '')#.replace('g', '')

                try:
                    # Attempt to convert to float
                    weight_in_kg = float(weight_str)
                except ValueError:
                    # Handle the case where the value is not a simple number
                    # might need custom logic here
                    # This is just an example, replace it with actual logic
                    # it could be '3 x 132g'
                    parts = weight_str.split('x')
                    if len(parts) == 2:
                        try:
                            weight_in_kg = float(parts[0]) * float(parts[1])
                        except ValueError:
                            weight_in_kg = None
                    else:
                        # Search for 'g' and 'ml' in the row and multiply the weight if found
                        if 'g' in weight_str:
                            try:
                                weight_in_kg = float(weight_str.replace('g', '')) * 0.001
                            except ValueError:
                                weight_in_kg = None
                        elif 'ml' in weight_str:
                            try:
                                weight_in_kg = float(weight_str.replace('ml', '')) * 0.001
                            except ValueError:
                                weight_in_kg = None
                        else:
                            weight_in_kg = None

            weights_in_kg.append(weight_in_kg)

        products_df['weight_kg'] = weights_in_kg

        # Remove unwanted characters from 'product_price' and change column name
        try:
            products_df['product_price_pound'] = (
                products_df['product_price']
                .str.replace('[^0-9.]', '', regex=True)  # Remove all non-numeric characters
                .astype(float)
            )
        except ValueError:
            # Handle the case where conversion to float is not possible
            # For example, set the value to NaN
            products_df['product_price_pound'] = float('nan')

        # Drop the original 'weight' and 'product_price' columns
        products_df.drop(columns=['weight', 'product_price'], inplace=True)

        return products_df

    def clean_products_data(self, products_df):
        # Implement any additional cleaning logic here
        # For example, handling missing values, removing duplicates, etc.

        return products_df

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
        cleaned_stores_df = stores_df.copy()  # Create a copy to avoid modifying the original DataFrame

        # Drop the 'lat' column
        cleaned_stores_df = cleaned_stores_df.drop(columns=['lat'], inplace=False)

        # Drop rows where 'continent' column has specific values
        values_to_drop = ['QMAVR5H3LD', 'LU3E036ZD9', '5586JCLARW', 'GFJQ2AAEQ8', 'SLQBD982C0', 'XQ953VS0FG', '1WZB1TE1HL']
        cleaned_stores_df = cleaned_stores_df[~cleaned_stores_df['continent'].isin(values_to_drop)]

        # Remove 'ee' prefix from 'continent'
        cleaned_stores_df['continent'] = cleaned_stores_df['continent'].str.replace('ee', '', regex=False)
        print(cleaned_stores_df["continent"].unique())

        # Handle formatting issues in 'opening_date'
        cleaned_stores_df['opening_date'] = pd.to_datetime(cleaned_stores_df['opening_date'], errors='coerce')

        return cleaned_stores_df
    
    def clean_orders_data(self, orders_df):
        # Remove specific columns from orders data
        orders_df.drop(columns=['first_name', 'last_name', '1'], inplace=True)

        # Additional cleaning logic if needed

        return orders_df
    
    def clean_date_events_data(self, date_events_df):
        try:
            # Print the columns of the DataFrame to identify the available columns
            print("Columns in date_events_df:", date_events_df.columns)

            # Check if 'date_uuid' is present in the DataFrame
            if 'date_uuid' in date_events_df.columns:
                # Convert the 'date_uuid' to datetime
                date_events_df['date_uuid'] = pd.to_datetime(date_events_df['date_uuid'], errors='coerce')

                # Additional cleaning logic if needed

                return date_events_df
            else:
                print("Error: 'date_uuid' not found in the DataFrame.")
                return None

        except Exception as e:
            print(f"Error cleaning date events data: {e}")
            return None

if __name__ == "__main__":
    data_clean_obj = DataCleaning()
    df = pd.read_csv("all_store_data.csv")
    cleaned_store_data = data_clean_obj.clean_store_data(df)
    cleaned_store_data.drop(columns="index", inplace=True)
    print(cleaned_store_data.columns)
    show(cleaned_store_data)
    


