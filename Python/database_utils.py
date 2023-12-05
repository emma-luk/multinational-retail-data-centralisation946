import yaml
import sqlalchemy as sa
import psycopg2

class DatabaseConnector:
    def __init__(self):
        self.engine = None

    def read_db_creds(self):
        with open('db_creds.yaml') as f:
            creds = yaml.safe_load(f)
        return creds

    def init_db_engine(self):
        creds = self.read_db_creds()
        engine_string = f'postgresql+psycopg2://{creds["RDS_USER"]}:{creds["RDS_PASSWORD"]}@{creds["RDS_HOST"]}:{creds["RDS_PORT"]}/{creds["RDS_DATABASE"]}'
        self.engine = sa.create_engine(engine_string)
        print(engine_string)
        return(self.engine)

    def list_db_tables(self):
        metdata = sa.inspect(self.engine)
        table_names = metdata.get_table_name()
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

