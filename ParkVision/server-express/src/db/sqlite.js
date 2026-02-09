const sqlite3 = require("sqlite3").verbose();
const path = require("path");

const dbPath = process.env.DB_PATH || "..\\demo_data\\database\\parking.db"; 
const resolved = path.resolve(__dirname, "..\\..\\", dbPath);

const db = new sqlite3.Database(resolved, (err) => {
  if (err) console.error("DB connection error:", err.message);
  else console.log("Connected to SQLite:", resolved);
});

// Recomendado por concurrencia (Python escribe / Node lee)
db.serialize(() => {
  db.run("PRAGMA journal_mode = WAL;");
  db.run("PRAGMA synchronous = NORMAL;");
  db.run("PRAGMA busy_timeout = 5000;");
});

function all(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => (err ? reject(err) : resolve(rows)));
  });
}

function get(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => (err ? reject(err) : resolve(row)));
  });
}

function run(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.run(sql, params, function (err) {
      if (err) return reject(err);
      resolve({ changes: this.changes, lastID: this.lastID });
    });
  });
}

module.exports = { db, all, get, run };
