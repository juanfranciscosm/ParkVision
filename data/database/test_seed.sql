-- =====================================================
-- PARKVISION - SEED DATA (FAKE DATA)
-- Fecha base: 3 de enero de 2026
-- =====================================================

PRAGMA foreign_keys = ON;

-- =====================================================
-- 1. PARKING
-- =====================================================
INSERT INTO parkings (name, address, total_spots)
VALUES (
    'Parking Central Campus',
    'Av. Universitaria 123, Guayaquil',
    12
);

-- =====================================================
-- 2. USERS (ADMIN / OPERATOR)
-- =====================================================
INSERT INTO users (parking_id, username, password_hash, role)
VALUES
(1, 'admin',    'hash_admin_123',    'ADMIN'),
(1, 'operador', 'hash_operador_456', 'OPERATOR');

-- =====================================================
-- 3. DRIVERS
-- =====================================================
INSERT INTO drivers (cedula, full_name, phone, email)
VALUES
('0901234567', 'Carlos Mendoza', '+593987654321', 'carlos@mail.com'),
('0912345678', 'Ana Torres',     '+593998877665', 'ana@mail.com'),
('0923456789', 'Luis Paredes',   '+593912345678', 'luis@mail.com'),
('0934567890', 'María Gómez',    '+593901234567', 'maria@mail.com'),
('0945678901', 'Pedro Salazar',  '+593955443322', 'pedro@mail.com');

-- =====================================================
-- 4. PARKING SPOTS
-- =====================================================
INSERT INTO parking_spots (id, parking_id, code, is_active)
VALUES
(0,  1, 'P0',  1),
(1,  1, 'P1',  1),
(2,  1, 'P2',  1),
(3,  1, 'P3',  1),
(4,  1, 'P4',  1),
(5,  1, 'P5',  1),
(6,  1, 'P6',  1),
(7,  1, 'P7',  1),
(8,  1, 'P8',  1),
(9,  1, 'P9',  1),
(10, 1, 'P10', 1),
(11, 1, 'P11', 1);

-- =====================================================
-- 5. PARKING SPOT STATE (ESTADO FINAL)
-- Ocupados: 1,2,8,10
-- =====================================================
INSERT INTO parking_spot_state (spot_id, status)
VALUES
(0,  'FREE'),
(1,  'OCCUPIED'),
(2,  'OCCUPIED'),
(3,  'FREE'),
(4,  'FREE'),
(5,  'FREE'),
(6,  'FREE'),
(7,  'FREE'),
(8,  'OCCUPIED'),
(9,  'FREE'),
(10, 'OCCUPIED'),
(11, 'FREE');

-- =====================================================
-- 6. OCCUPANCY SESSIONS (HISTÓRICO)
-- =====================================================
INSERT INTO occupancy_sessions
(spot_id, started_at, ended_at, duration_seconds, source)
VALUES
-- Plaza 1 (ocupada)
(1, '2026-01-03 07:45:00', '2026-01-03 09:15:00', 5400, 'VISION'),
(1, '2026-01-03 10:00:00', NULL,                 NULL, 'VISION'),

-- Plaza 2 (ocupada)
(2, '2026-01-03 08:30:00', NULL,                 NULL, 'VISION'),

-- Plaza 3 (libre)
(3, '2026-01-03 07:00:00', '2026-01-03 08:10:00', 4200, 'VISION'),

-- Plaza 6 (libre)
(6, '2026-01-03 09:00:00', '2026-01-03 10:20:00', 4800, 'VISION'),

-- Plaza 8 (ocupada)
(8, '2026-01-03 06:50:00', '2026-01-03 08:30:00', 6000, 'VISION'),
(8, '2026-01-03 09:10:00', NULL,                 NULL, 'VISION'),

-- Plaza 10 (ocupada)
(10,'2026-01-03 08:00:00', NULL,                 NULL, 'VISION'),

-- Plaza 11 (libre)
(11,'2026-01-03 07:20:00', '2026-01-03 07:55:00', 2100, 'VISION');

-- =====================================================
-- 7. RESERVATIONS
-- =====================================================
INSERT INTO reservations
(spot_id, driver_id, qr_code, reserved_at, expires_at, confirmed_at, status)
VALUES
(2,  1, 'QR-2026-001', '2026-01-03 07:00:00', '2026-01-03 07:30:00', '2026-01-03 07:10:00', 'CONFIRMED'),
(4,  2, 'QR-2026-002', '2026-01-03 08:00:00', '2026-01-03 08:30:00', NULL,                'EXPIRED'),
(5,  3, 'QR-2026-003', '2026-01-03 06:30:00', '2026-01-03 07:00:00', NULL,                'EXPIRED'),
(7,  4, 'QR-2026-004', '2026-01-03 09:00:00', '2026-01-03 09:45:00', NULL,                'CANCELLED');

-- =====================================================
-- 8. EVENTS (AUDITORÍA)
-- =====================================================
INSERT INTO events (spot_id, event_type, metadata)
VALUES
(1,  'OCCUPIED', '{"source":"VISION","time":"07:45"}'),
(1,  'OCCUPIED', '{"source":"VISION","time":"10:00"}'),
(2,  'OCCUPIED', '{"source":"VISION","time":"08:30"}'),
(3,  'FREED',    '{"source":"VISION","time":"08:10"}'),
(6,  'FREED',    '{"source":"VISION","time":"10:20"}'),
(8,  'OCCUPIED', '{"source":"VISION","time":"09:10"}'),
(10, 'OCCUPIED', '{"source":"VISION","time":"08:00"}'),
(2,  'RESERVED', '{"driver_id":1,"qr":"QR-2026-001"}'),
(4,  'EXPIRED',  '{"qr":"QR-2026-002"}'),
(5,  'EXPIRED',  '{"qr":"QR-2026-003"}');
