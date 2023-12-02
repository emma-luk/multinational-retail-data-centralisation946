import pandas as pd

class DataCleaning:
    def clean_user_data(self, data):
        # Method to clean user data
        # Check for NULL values
        data = data.dropna()

        # Validate dates
        data['date_of_birth'] = pd.to_datetime(data['date_of_birth'])

        # Check for incorrectly typed values
        data['country'] = data['country'].apply(lambda x: x.upper())

        # Remove rows with incorrect information
        data = data[data['country'] != 'INVALID']

        return data
