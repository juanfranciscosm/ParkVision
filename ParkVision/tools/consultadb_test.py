import sqlite3

conn = sqlite3.connect("data/database/parking.db")
cur = conn.cursor()

print("ESTADO ACTUAL:")
cur.execute("SELECT * FROM parkings")
print(cur.fetchall())

conn.close()
