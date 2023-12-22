# Multinational Retail Data Centralisation Project

## Table of Contents
- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
- [File Structure](#file-structure)
- [License](#license)

## Description
This project aims to centralise and make accessible the sales data of a multinational company that sells various goods across the globe. The current sales data is distributed across multiple sources, making it challenging to analyse. The organisation's goal is to become more data-driven, and this project addresses the data centralisation needs.

### Project Tasks
The project involves the following tasks:
1. Extracting and cleaning user data
2. Extracting users and cleaning card details
3. Extracting and cleaning details of each store
4. Extracting and cleaning product details
5. Retrieving and cleaning the orders table
6. Retrieving and cleaning date events data

## Installation
To run this project, follow these steps:

1. Clone the repository:
   ```bash
   git clone https://github.com/emma-luk/multinational-retail-data-centralisation946.git
   cd Python

2. Install the required dependencies:
   pip install -r requirements.txt

3. Set up the necessary database credentials. Refer to db_creds.yaml and local_credentials.yaml for examples.

## Usage
Execute the main script main.py to perform the data extraction, transformation, and loading (ETL) tasks. Ensure that the required API key and URLs are configured in the script.

python main.py

multinational-retail-data-centralisation/
|-- Python/
|   |-- main.py
|   |-- data_extraction.py
|   |-- data_cleaning.py
|   |-- database_utils.py
|   |-- db_creds.yaml
|   |-- local_credentials.yaml
|-- README.md
|-- requirements.txt

### License

Feel free to customise the content as needed. Add more details or sections based on your project's specific requirements. Make sure to update the information in square brackets (e.g., `[your-username]`, `[your-project-name]`, etc.) with your actual details.
