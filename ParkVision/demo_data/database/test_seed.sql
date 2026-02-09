-- =====================================================
-- PARKVISION - SEED DATA (ESTACIONAMIENTO PARQUE AJA)
-- Fecha base: 3 de enero de 2026
-- =====================================================

PRAGMA foreign_keys = ON;

-- =====================================================
-- 1. PARKING
-- =====================================================
INSERT INTO parkings (name, address, total_spots)
VALUES (
    'PARQUE AJA',
    'CAMPUS GUSTAVO GALINDO, ESPOL',
    7
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
(6,  1, 'P6',  1);

-- =====================================================
-- 5. PARKING SPOT STATE (ESTADO INICIAL)
-- =====================================================
INSERT INTO parking_spot_state (spot_id, status)
VALUES
(0,  'FREE'),
(1,  'OCCUPIED'),
(2,  'OCCUPIED'),
(3,  'FREE'),
(4,  'FREE'),
(5,  'FREE'),
(6,  'FREE');


-- =====================================================
-- 7. RESERVATIONS
-- =====================================================
INSERT INTO reservations
(spot_id, driver_id, qr_code, reserved_at, expires_at, confirmed_at, status)
VALUES
(4,  2, 'QR-2026-002', '2026-01-03 08:00:00', '2026-01-03 08:30:00', NULL,                'EXPIRED'),
(5,  3, 'QR-2026-003', '2026-01-03 06:30:00', '2026-01-03 07:00:00', NULL,                'EXPIRED'),
(6,  4, 'QR-2026-004', '2026-01-03 09:00:00', '2026-01-03 09:45:00', NULL,                'CANCELLED');

-- =====================================================
-- 8. EVENTS (AUDITORÍA)
-- =====================================================
INSERT INTO events (spot_id, event_type, metadata)
VALUES
(2,  'RESERVED', '{"driver_id":1,"qr":"QR-2026-001"}'),
(4,  'EXPIRED',  '{"qr":"QR-2026-002"}'),
(5,  'EXPIRED',  '{"qr":"QR-2026-003"}');
