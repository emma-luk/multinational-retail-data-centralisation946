#database_utils.py
import yaml
import sqlalchemy as sa
import psycopg2

class DatabaseConnector:
    def __init__(self, cred):
        cred = self.read_db_creds(cred)
        self.engine = self.init_db_engine(cred)

    def upload_products_to_db(self, products_data, table_name='dim_products'):
        # Use the upload_to_db method to insert data into the specified table
        self.upload_to_db(products_data, table_name)

    def read_db_creds(self, filename):
        with open(filename, 'r') as f:
            creds = yaml.safe_load(f)
        return creds

    def init_db_engine(self, creds):
        engine_string = f'postgresql+psycopg2://{creds["RDS_USER"]}:{creds["RDS_PASSWORD"]}@{creds["RDS_HOST"]}:{creds["RDS_PORT"]}/{creds["RDS_DATABASE"]}'
        self.engine = sa.create_engine(engine_string)
        print(engine_string)
        return(self.engine)

    def list_db_tables(self):
        metdata = sa.inspect(self.engine)
        table_names = metdata.get_table_names()
        print(table_names)
        return table_names

    def upload_to_db(self, data, table_name, engine=None):
        if not engine:
            engine = self.engine

        with engine.begin() as transaction:
            data.to_sql(table_name, engine, if_exists='replace', index=False)
            transaction.commit()


if __name__ == '__main__':
    db = DatabaseConnector ("D:\development\projects\multinational-retail-data-centralisation946\Python\db_creds.yaml")
    db.list_db_tables()
    db2 = DatabaseConnector("D:\development\projects\multinational-retail-data-centralisation946\Python\local_credentials.yaml")