import pg8000
from getpass import getpass


class Connection:
    def __init__(self):
        self.connection = pg8000.connect(
            user="twsellers",  # Replace with your username
            password=getpass(),
            host="ada.mines.edu",
            port=5432,
            database="csci403"
        )
    
    def get_connection(self):
        return self.connection