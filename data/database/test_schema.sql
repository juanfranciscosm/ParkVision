CREATE TABLE plazas (
    id INTEGER PRIMARY KEY,
    nombre TEXT
);

CREATE TABLE estado_actual (
    plaza_id INTEGER PRIMARY KEY,
    ocupada BOOLEAN,
    last_update TIMESTAMP,
    FOREIGN KEY (plaza_id) REFERENCES plazas(id)
);

CREATE TABLE sesiones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    plaza_id INTEGER,
    inicio TIMESTAMP,
    fin TIMESTAMP,
    duracion_segundos INTEGER,
    FOREIGN KEY (plaza_id) REFERENCES plazas(id)
);