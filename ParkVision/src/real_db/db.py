import sqlite3
from pathlib import Path
from contextlib import contextmanager

DB_PATH = Path("data/database/parking.db")

# =========================
# CONEXIÓN PERSISTENTE (VISION)
# =========================

_vision_connection = None

def get_vision_connection():
    global _vision_connection
    if _vision_connection is None:
        _vision_connection = sqlite3.connect(
            DB_PATH,
            timeout=30,
            check_same_thread=False
        )
        _vision_connection.row_factory = sqlite3.Row
        _vision_connection.execute("PRAGMA journal_mode=WAL;")
        _vision_connection.execute("PRAGMA synchronous=NORMAL;")
    return _vision_connection


# =========================
# CONEXIÓN SEGURA (API)
# =========================

@contextmanager
def get_api_connection():
    conn = sqlite3.connect(
        DB_PATH,
        timeout=30,
        check_same_thread=False
    )
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        conn.close()
