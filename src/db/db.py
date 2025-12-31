import sqlite3

def get_connection():
    return sqlite3.connect("data/database/test_parking.db", check_same_thread=False)
