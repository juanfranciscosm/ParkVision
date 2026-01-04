-- =====================================================
-- PARKVISION - DATABASE SCHEMA (v1.0)
-- =====================================================
-- Compatible con SQLite / PostgreSQL
-- =====================================================

PRAGMA foreign_keys = ON;

-- =====================================================
-- 1. PARKINGS (entidad raíz)
-- =====================================================
CREATE TABLE parkings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    total_spots INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. USERS (admins / operadores)
-- Cada user pertenece a UN parking
-- =====================================================
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parking_id INTEGER NOT NULL,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT CHECK(role IN ('ADMIN','OPERATOR')) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parking_id) REFERENCES parkings(id)
);

-- =====================================================
-- 3. DRIVERS (usuarios finales que reservan)
-- Identificados por cédula
-- =====================================================
CREATE TABLE drivers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cedula TEXT UNIQUE NOT NULL,
    full_name TEXT,
    phone TEXT,
    email TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 4. PARKING SPOTS (plazas físicas)
-- Cada plaza pertenece a UN parking
-- =====================================================
CREATE TABLE parking_spots (
    id INTEGER PRIMARY KEY,
    parking_id INTEGER NOT NULL,
    code TEXT NOT NULL,
    is_active BOOLEAN DEFAULT 1,
    UNIQUE (parking_id, code),
    FOREIGN KEY (parking_id) REFERENCES parkings(id)
);

-- =====================================================
-- 5. PARKING SPOT STATE (estado en tiempo real)
-- UNA fila por plaza
-- =====================================================
CREATE TABLE parking_spot_state (
    spot_id INTEGER PRIMARY KEY,
    status TEXT CHECK(status IN ('FREE','RESERVED','OCCUPIED')) NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (spot_id) REFERENCES parking_spots(id)
);

-- =====================================================
-- 6. OCCUPANCY SESSIONS (historial de ocupación)
-- Base para analítica y mapas de calor
-- =====================================================
CREATE TABLE occupancy_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    spot_id INTEGER NOT NULL,
    started_at DATETIME NOT NULL,
    ended_at DATETIME,
    duration_seconds INTEGER,
    source TEXT DEFAULT 'VISION', -- VISION / QR / MANUAL
    FOREIGN KEY (spot_id) REFERENCES parking_spots(id)
);

-- =====================================================
-- 7. RESERVATIONS (reservas con QR)
-- Relaciona drivers con plazas
-- =====================================================
CREATE TABLE reservations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    spot_id INTEGER NOT NULL,
    driver_id INTEGER NOT NULL,
    qr_code TEXT UNIQUE NOT NULL,
    reserved_at DATETIME NOT NULL,
    expires_at DATETIME NOT NULL,
    confirmed_at DATETIME,
    cancelled_at DATETIME,
    status TEXT CHECK(status IN ('ACTIVE','CONFIRMED','EXPIRED','CANCELLED')) NOT NULL,
    FOREIGN KEY (spot_id) REFERENCES parking_spots(id),
    FOREIGN KEY (driver_id) REFERENCES drivers(id)
);

-- =====================================================
-- 8. EVENTS (auditoría y trazabilidad)
-- Registra TODO lo que ocurre en el sistema
-- =====================================================
CREATE TABLE events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    spot_id INTEGER,
    event_type TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    metadata TEXT,
    FOREIGN KEY (spot_id) REFERENCES parking_spots(id)
);

-- =====================================================
-- ÍNDICES 
-- =====================================================
CREATE INDEX idx_parking_spots_parking
    ON parking_spots(parking_id);

CREATE INDEX idx_spot_state_status
    ON parking_spot_state(status);

CREATE INDEX idx_sessions_spot
    ON occupancy_sessions(spot_id);

CREATE INDEX idx_reservations_spot
    ON reservations(spot_id);

CREATE INDEX idx_reservations_driver
    ON reservations(driver_id);

CREATE INDEX idx_events_spot
    ON events(spot_id);
