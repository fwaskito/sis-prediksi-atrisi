import mysql.connector as connector
from mysql.connector import Error

class MysqlServer():
    def connect(self, db_name="mydb"):
        try:
            conn = connector.connect(host='localhost',
                                    database=db_name,
                                    user='waskito',
                                    password='admwaskito')
            
            if conn.is_connected():
                db_info = conn.get_server_info()
                print("Connected to MySQL Server version ", db_info, "\n")
                return conn
        except Error as e:
            print("Error while connecting to MySQL!\n", e)
    
    def close_cursor(self, conn, cursor):
        if conn.is_connected():
            cursor.close()
            print("\nMySQL cursor is closed.")

    def close_connection(self, conn):
        if conn.is_connected():
            conn.close()
            print("\nMySQL connection is closed.")



    """
    if __name__ == "__main__":
        conn = connect()
    """
