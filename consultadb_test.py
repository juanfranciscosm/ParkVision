import sqlite3

conn = sqlite3.connect("data/database/test_parking.db")
cur = conn.cursor()

print("ESTADO ACTUAL:")
cur.execute("SELECT * FROM plazas")
print(cur.fetchall())

print("\nSESIONES:")
cur.execute("SELECT * FROM sesiones")
print(cur.fetchall())

conn.close()
