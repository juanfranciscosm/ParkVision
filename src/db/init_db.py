import sqlite3
from pathlib import Path

DB_PATH = Path("data/database/test_parking.db")
SCHEMA_PATH = Path("data/database/test_schema.sql")
SEED_PATH = Path("data/database/test_seed.sql")

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    cur.executescript(SCHEMA_PATH.read_text())
    cur.executescript(SEED_PATH.read_text())

    conn.commit()
    conn.close()
    print("Base de datos creada correctamente")

if __name__ == "__main__":
    init_db()
