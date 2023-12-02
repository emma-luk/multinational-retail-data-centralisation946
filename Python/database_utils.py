import yaml
import sqlalchemy as sa

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

    def list_db_tables(self):
        metadata = sa.MetaData()
        metadata.reflect(self.engine)
        return metadata.tables

    def read_rds_table(self, table_name):
        data = pd.read_sql_table(table_name, self.engine)
        return data

    def upload_to_db(self, data, table_name):
        data.to_sql(table_name, self.engine, if_exists='replace', index=False)
