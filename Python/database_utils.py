import psycopg2

class DatabaseConnector:

    def connect_to_database(self, database_name, user, password):
        # Connect to PostgreSQL database
        connection = psycopg2.connect(
            dbname=database_name,
            user=user,
            password=password,
            host="localhost"
        )
        return connection

    def upload_data_to_database(self, connection, table_name, data):
        # Upload data to PostgreSQL database
        cursor = connection.cursor()
        cursor.execute("INSERT INTO {} VALUES %s".format(table_name), data)
        connection.commit()
        cursor.close()
