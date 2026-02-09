import sqlite3
from pathlib import Path

DB_PATH = Path("data/database/parking.db")
SCHEMA_PATH = Path("data/database/schema.sql")
SEED_PATH = Path("data/database/seed.sql")
SEED6months_PATH = Path("data/database/seed_6months.sql")

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    cur.executescript(SCHEMA_PATH.read_text(encoding="utf-8"))
    cur.executescript(SEED_PATH.read_text(encoding="utf-8"))
    cur.executescript(SEED6months_PATH.read_text(encoding="utf-8"))

    conn.commit()
    conn.close()
    print("Base de datos creada correctamente")

if __name__ == "__main__":
    init_db()
