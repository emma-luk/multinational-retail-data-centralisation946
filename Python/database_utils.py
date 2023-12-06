import yaml
import sqlalchemy as sa
import psycopg2
#from database_utils import DatabaseConnector

class DatabaseConnector:
    def __init__(self, cred):
        cred = self.read_db_creds(cred)
        self.engine = self.init_db_engine(cred)

    def read_db_creds(self, filename):
        with open(filename, 'r') as f:
            creds = yaml.safe_load(f)
        return creds
    # Read database credentials from db_creds.yaml
    #db_creds = db_connector.read_db_creds('db_creds.yaml')
    
    # Initialize the database engine using the credentials
    #engine = db_connector.init_db_engine(db_creds)

    def init_db_engine(self, creds):
        #creds = self.read_db_creds()
        #creds = self.read_db_creds('credentials.yaml')  # Pass the filename explicitly
        # Load credentials from YAML file
        #creds = yaml.safe_load(open('credentials.yaml', 'r'))
        engine_string = f'postgresql+psycopg2://{creds["RDS_USER"]}:{creds["RDS_PASSWORD"]}@{creds["RDS_HOST"]}:{creds["RDS_PORT"]}/{creds["RDS_DATABASE"]}'
        #self.engine = sa.create_engine(engine_string)
        # Create the database engine using the extracted credentials
        self.engine = sa.create_engine(engine_string)
        print(engine_string)
        return(self.engine)

    def list_db_tables(self):
        metdata = sa.inspect(self.engine)
        table_names = metdata.get_table_names()
        print(table_names)
        return table_names
        #metadata = sa.MetaData()
        #metadata.reflect(self.engine)
        #print(metadata.tables)
        #FIXME:
        #return metadata.tables

    #def upload_to_db(self, data, table_name):
        #data.to_sql(table_name, self.engine, if_exists='replace', index=False)

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