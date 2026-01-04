import sqlite3
from pathlib import Path

DB_PATH = Path("data/database/parking.db")

_connection = None

def get_connection():
    global _connection
    if _connection is None:
        _connection = sqlite3.connect(
            DB_PATH,
            timeout=30,
            check_same_thread=False
        )
        _connection.row_factory = sqlite3.Row
        _connection.execute("PRAGMA journal_mode=WAL;")
        _connection.execute("PRAGMA synchronous=NORMAL;")
    return _connection
