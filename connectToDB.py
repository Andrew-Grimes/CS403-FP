import pg8000
from getpass import getpass

connection = pg8000.connect(
    user="UPDATE_ME",  # Replace with your username
    password=getpass(),
    host="ada.mines.edu",
    port=5432,
    database="csci403"
)