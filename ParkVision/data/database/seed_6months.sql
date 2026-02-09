PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- =====================================================
-- DRIVERS EXTRA (IDs fijos para referenciar en reservas)
-- (Drivers base: 1..5 ya existen en tu seed)
-- =====================================================
INSERT OR IGNORE INTO drivers (id, cedula, full_name, phone, email, created_at) VALUES
(6,  '0950000006',  'Daniel Vera',        '+593980000006', 'dvera6@mail.com',  '2025-08-01 08:00:00'),
(7,  '0950000007',  'Sofia Mena',         '+593980000007', 'smena7@mail.com',  '2025-08-02 08:00:00'),
(8,  '0950000008',  'Jorge Cedeño',       '+593980000008', 'jcedeno8@mail.com','2025-08-03 08:00:00'),
(9,  '0950000009',  'Valeria Loor',       '+593980000009', 'vloor9@mail.com',  '2025-08-04 08:00:00'),
(10, '0950000010',  'Kevin Zambrano',     '+593980000010', 'kzam10@mail.com',  '2025-08-05 08:00:00'),
(11, '0950000011',  'Paula Solís',        '+593980000011', 'psolis11@mail.com','2025-08-06 08:00:00'),
(12, '0950000012',  'Andrés Paredes',     '+593980000012', 'apared12@mail.com','2025-08-07 08:00:00'),
(13, '0950000013',  'Camila Cárdenas',    '+593980000013', 'ccard13@mail.com', '2025-08-08 08:00:00'),
(14, '0950000014',  'Diego Herrera',      '+593980000014', 'dherr14@mail.com', '2025-08-09 08:00:00'),
(15, '0950000015',  'Gabriela Peñafiel',  '+593980000015', 'gpena15@mail.com', '2025-08-10 08:00:00'),
(16, '0950000016',  'Mateo Ruiz',         '+593980000016', 'mruiz16@mail.com', '2025-08-11 08:00:00'),
(17, '0950000017',  'Natalia Chica',      '+593980000017', 'nchica17@mail.com','2025-08-12 08:00:00'),
(18, '0950000018',  'Esteban León',       '+593980000018', 'eleon18@mail.com', '2025-08-13 08:00:00'),
(19, '0950000019',  'Michelle Vera',      '+593980000019', 'mvera19@mail.com', '2025-08-14 08:00:00'),
(20, '0950000020',  'Ricardo Rivas',      '+593980000020', 'rrivas20@mail.com','2025-08-15 08:00:00'),
(21, '0950000021',  'Nicolás Paz',        '+593980000021', 'npaz21@mail.com',  '2025-08-16 08:00:00'),
(22, '0950000022',  'Karla Molina',       '+593980000022', 'kmol22@mail.com',  '2025-08-17 08:00:00'),
(23, '0950000023',  'Sebastián Vega',     '+593980000023', 'sveg23@mail.com',  '2025-08-18 08:00:00'),
(24, '0950000024',  'María José López',   '+593980000024', 'mjlo24@mail.com',  '2025-08-19 08:00:00'),
(25, '0950000025',  'Luis Castillo',      '+593980000025', 'lcast25@mail.com', '2025-08-20 08:00:00'),
(26, '0950000026',  'Andrea Roldán',      '+593980000026', 'arol26@mail.com',  '2025-08-21 08:00:00'),
(27, '0950000027',  'Javier Pino',        '+593980000027', 'jpino27@mail.com', '2025-08-22 08:00:00'),
(28, '0950000028',  'Alejandra Díaz',     '+593980000028', 'adiaz28@mail.com', '2025-08-23 08:00:00'),
(29, '0950000029',  'Fernando Arce',      '+593980000029', 'farce29@mail.com', '2025-08-24 08:00:00'),
(30, '0950000030',  'Daniela Viteri',     '+593980000030', 'dvite30@mail.com', '2025-08-25 08:00:00'),
(31, '0950000031',  'Bruno Luna',         '+593980000031', 'bluna31@mail.com', '2025-08-26 08:00:00'),
(32, '0950000032',  'Carolina Mora',      '+593980000032', 'cmora32@mail.com', '2025-08-27 08:00:00'),
(33, '0950000033',  'Iván Freire',        '+593980000033', 'ifreire33@mail.com','2025-08-28 08:00:00'),
(34, '0950000034',  'Diana Coronel',      '+593980000034', 'dcor34@mail.com',  '2025-08-29 08:00:00'),
(35, '0950000035',  'Pablo Lara',         '+593980000035', 'plara35@mail.com', '2025-08-30 08:00:00'),
(36, '0950000036',  'Melissa Cedeño',     '+593980000036', 'mced36@mail.com',  '2025-08-31 08:00:00'),
(37, '0950000037',  'Juan Medina',        '+593980000037', 'jmed37@mail.com',  '2025-09-01 08:00:00'),
(38, '0950000038',  'Katherine León',     '+593980000038', 'kleon38@mail.com', '2025-09-02 08:00:00'),
(39, '0950000039',  'Carlos Pacheco',     '+593980000039', 'cpach39@mail.com', '2025-09-03 08:00:00'),
(40, '0950000040',  'Santiago Solano',    '+593980000040', 'ssol40@mail.com',  '2025-09-04 08:00:00'),
(41, '0950000041',  'Dayana Molina',      '+593980000041', 'dmol41@mail.com',  '2025-09-05 08:00:00'),
(42, '0950000042',  'Erick Rosero',       '+593980000042', 'erose42@mail.com', '2025-09-06 08:00:00'),
(43, '0950000043',  'Viviana Ponce',      '+593980000043', 'vpon43@mail.com',  '2025-09-07 08:00:00'),
(44, '0950000044',  'Gustavo Silva',      '+593980000044', 'gsil44@mail.com',  '2025-09-08 08:00:00'),
(45, '0950000045',  'Martina Rivas',      '+593980000045', 'mriv45@mail.com',  '2025-09-09 08:00:00'),
(46, '0950000046',  'José Andrade',       '+593980000046', 'jand46@mail.com',  '2025-09-10 08:00:00'),
(47, '0950000047',  'Paola Lema',         '+593980000047', 'plem47@mail.com',  '2025-09-11 08:00:00'),
(48, '0950000048',  'Hugo Guerra',        '+593980000048', 'hgue48@mail.com',  '2025-09-12 08:00:00'),
(49, '0950000049',  'Rocío Cárdenas',     '+593980000049', 'rcar49@mail.com',  '2025-09-13 08:00:00'),
(50, '0950000050',  'Mauricio Torres',    '+593980000050', 'mtor50@mail.com',  '2025-09-14 08:00:00'),
(51, '0950000051',  'Bianca Mora',        '+593980000051', 'bmor51@mail.com',  '2025-09-15 08:00:00'),
(52, '0950000052',  'Cristian Paz',       '+593980000052', 'cpaz52@mail.com',  '2025-09-16 08:00:00'),
(53, '0950000053',  'Patricia Guamán',    '+593980000053', 'pgua53@mail.com',  '2025-09-17 08:00:00'),
(54, '0950000054',  'Renato Vázquez',     '+593980000054', 'rvaz54@mail.com',  '2025-09-18 08:00:00'),
(55, '0950000055',  'Melanie Bravo',      '+593980000055', 'mbr55@mail.com',   '2025-09-19 08:00:00'),
(56, '0950000056',  'César Delgado',      '+593980000056', 'cdel56@mail.com',  '2025-09-20 08:00:00'),
(57, '0950000057',  'Adriana Mena',       '+593980000057', 'amen57@mail.com',  '2025-09-21 08:00:00'),
(58, '0950000058',  'Wilson Cedeño',      '+593980000058', 'wced58@mail.com',  '2025-09-22 08:00:00'),
(59, '0950000059',  'Liliana Ruiz',       '+593980000059', 'lruiz59@mail.com', '2025-09-23 08:00:00'),
(60, '0950000060',  'Álvaro Sornoza',     '+593980000060', 'asor60@mail.com',  '2025-09-24 08:00:00');

-- =====================================================
-- OCCUPANCY SESSIONS (6 meses)
-- Genera patrón con picos aprox. 09:00 y 18:00
-- - Lunes a Viernes: 2 sesiones por plaza (mañana + tarde)
-- - Sábado: 1 sesión por plaza (media mañana)
-- - Domingo: 1 sesión (solo plazas pares, mediodía)
-- =====================================================

-- 1) Lunes a Viernes - Sesión mañana (pico ~09h)
WITH RECURSIVE
days(d) AS (
  SELECT date('2025-08-01')
  UNION ALL
  SELECT date(d, '+1 day') FROM days WHERE d < date('2026-01-25')
),
spots(sid) AS (
  SELECT 0 UNION ALL SELECT sid + 1 FROM spots WHERE sid < 7
),
wd AS (
  SELECT d, sid, CAST(strftime('%w', d) AS INTEGER) AS w
  FROM days CROSS JOIN spots
)
INSERT INTO occupancy_sessions (spot_id, started_at, ended_at, duration_seconds, source)
SELECT
  sid,
  datetime(d || ' 08:45:00', printf('+%d minutes', sid)), -- 08:45..08:52
  datetime(d || ' 08:45:00', printf('+%d minutes', sid + (25 + sid*4))), -- 25..53 min
  (25 + sid*4) * 60,
  'VISION'
FROM wd
WHERE w BETWEEN 1 AND 5;

-- 2) Lunes a Viernes - Sesión tarde (pico ~18h)
WITH RECURSIVE
days(d) AS (
  SELECT date('2025-08-01')
  UNION ALL
  SELECT date(d, '+1 day') FROM days WHERE d < date('2026-01-25')
),
spots(sid) AS (
  SELECT 0 UNION ALL SELECT sid + 1 FROM spots WHERE sid < 7
),
wd AS (
  SELECT d, sid, CAST(strftime('%w', d) AS INTEGER) AS w
  FROM days CROSS JOIN spots
)
INSERT INTO occupancy_sessions (spot_id, started_at, ended_at, duration_seconds, source)
SELECT
  sid,
  datetime(d || ' 17:50:00', printf('+%d minutes', sid*2)), -- 17:50..18:04
  datetime(d || ' 17:50:00', printf('+%d minutes', sid*2 + (35 + sid*5))), -- 35..70 min
  (35 + sid*5) * 60,
  'VISION'
FROM wd
WHERE w BETWEEN 1 AND 5;

-- 3) Sábado (w=6) - Media mañana
WITH RECURSIVE
days(d) AS (
  SELECT date('2025-08-01')
  UNION ALL
  SELECT date(d, '+1 day') FROM days WHERE d < date('2026-01-25')
),
spots(sid) AS (
  SELECT 0 UNION ALL SELECT sid + 1 FROM spots WHERE sid < 7
),
wd AS (
  SELECT d, sid, CAST(strftime('%w', d) AS INTEGER) AS w
  FROM days CROSS JOIN spots
)
INSERT INTO occupancy_sessions (spot_id, started_at, ended_at, duration_seconds, source)
SELECT
  sid,
  datetime(d || ' 10:20:00', printf('+%d minutes', sid)), -- 10:20..10:27
  datetime(d || ' 10:20:00', printf('+%d minutes', sid + (30 + sid*3))), -- 30..51 min
  (30 + sid*3) * 60,
  'VISION'
FROM wd
WHERE w = 6;

-- 4) Domingo (w=0) - Mediodía (solo plazas pares)
WITH RECURSIVE
days(d) AS (
  SELECT date('2025-08-01')
  UNION ALL
  SELECT date(d, '+1 day') FROM days WHERE d < date('2026-01-25')
),
spots(sid) AS (
  SELECT 0 UNION ALL SELECT sid + 1 FROM spots WHERE sid < 7
),
wd AS (
  SELECT d, sid, CAST(strftime('%w', d) AS INTEGER) AS w
  FROM days CROSS JOIN spots
)
INSERT INTO occupancy_sessions (spot_id, started_at, ended_at, duration_seconds, source)
SELECT
  sid,
  datetime(d || ' 12:10:00', printf('+%d minutes', sid)), -- 12:10..12:17
  datetime(d || ' 12:10:00', printf('+%d minutes', sid + (28 + sid*2))), -- 28..42 min
  (28 + sid*2) * 60,
  'VISION'
FROM wd
WHERE w = 0 AND (sid % 2 = 0);

-- =====================================================
-- RESERVATIONS (6 meses)
-- 1 reserva cada 2 días, spot rota por día (0..7)
-- Estados distribuidos:
-- - cada 10 días -> CANCELLED
-- - cada 4 días  -> CONFIRMED
-- - resto        -> EXPIRED
-- Nota: no se valida QR en tu alcance, pero CONFIRMED sirve para analítica.
-- =====================================================
WITH RECURSIVE
days(d) AS (
  SELECT date('2025-08-01')
  UNION ALL
  SELECT date(d, '+1 day') FROM days WHERE d < date('2026-01-25')
),
indexed AS (
  SELECT
    d,
    CAST(julianday(d) - julianday('2025-08-01') AS INTEGER) AS day_index
  FROM days
)
INSERT INTO reservations (spot_id, driver_id, qr_code, reserved_at, expires_at, confirmed_at, cancelled_at, status)
SELECT
  (day_index % 8) AS spot_id,
  (1 + (day_index % 60)) AS driver_id, -- usa drivers 1..60
  printf('QR-%s-%03d-%d', strftime('%Y%m', d), day_index, (day_index % 8)) AS qr_code,
  datetime(d || ' 08:00:00') AS reserved_at,
  datetime(d || ' 08:15:00') AS expires_at,
  CASE WHEN (day_index % 4 = 0) AND (day_index % 10 != 0)
       THEN datetime(d || ' 08:02:00') ELSE NULL END AS confirmed_at,
  CASE WHEN (day_index % 10 = 0)
       THEN datetime(d || ' 08:05:00')
       WHEN (day_index % 4 != 0)
       THEN datetime(d || ' 08:16:00')
       ELSE NULL END AS cancelled_at,
  CASE WHEN (day_index % 10 = 0) THEN 'CANCELLED'
       WHEN (day_index % 4 = 0) THEN 'CONFIRMED'
       ELSE 'EXPIRED' END AS status
FROM indexed
WHERE (day_index % 2 = 0);

-- =====================================================
-- EVENTS (opcional, para trazabilidad)
-- 1 evento por reserva creada + 1 por resultado (expired/cancelled/confirmed)
-- =====================================================
WITH RECURSIVE
days(d) AS (
  SELECT date('2025-08-01')
  UNION ALL
  SELECT date(d, '+1 day') FROM days WHERE d < date('2026-01-25')
),
indexed AS (
  SELECT
    d,
    CAST(julianday(d) - julianday('2025-08-01') AS INTEGER) AS day_index
  FROM days
),
res AS (
  SELECT
    d,
    day_index,
    (day_index % 8) AS spot_id,
    printf('QR-%s-%03d-%d', strftime('%Y%m', d), day_index, (day_index % 8)) AS qr_code,
    CASE WHEN (day_index % 10 = 0) THEN 'CANCELLED'
         WHEN (day_index % 4 = 0) THEN 'CONFIRMED'
         ELSE 'EXPIRED' END AS status
  FROM indexed
  WHERE (day_index % 2 = 0)
)
INSERT INTO events (spot_id, event_type, created_at, metadata)
SELECT
  spot_id,
  'RESERVATION_CREATED',
  datetime(d || ' 08:00:00'),
  json_object('qr', qr_code, 'status', 'ACTIVE')
FROM res;

WITH RECURSIVE
days(d) AS (
  SELECT date('2025-08-01')
  UNION ALL
  SELECT date(d, '+1 day') FROM days WHERE d < date('2026-01-25')
),
indexed AS (
  SELECT
    d,
    CAST(julianday(d) - julianday('2025-08-01') AS INTEGER) AS day_index
  FROM days
),
res AS (
  SELECT
    d,
    day_index,
    (day_index % 8) AS spot_id,
    printf('QR-%s-%03d-%d', strftime('%Y%m', d), day_index, (day_index % 8)) AS qr_code,
    CASE WHEN (day_index % 10 = 0) THEN 'CANCELLED'
         WHEN (day_index % 4 = 0) THEN 'CONFIRMED'
         ELSE 'EXPIRED' END AS status
  FROM indexed
  WHERE (day_index % 2 = 0)
)
INSERT INTO events (spot_id, event_type, created_at, metadata)
SELECT
  spot_id,
  CASE WHEN status='CANCELLED' THEN 'RESERVATION_CANCELLED'
       WHEN status='CONFIRMED' THEN 'RESERVATION_CONFIRMED'
       ELSE 'RESERVATION_EXPIRED' END,
  CASE WHEN status='CONFIRMED' THEN datetime(d || ' 08:02:00')
       WHEN status='CANCELLED' THEN datetime(d || ' 08:05:00')
       ELSE datetime(d || ' 08:16:00') END,
  json_object('qr', qr_code, 'final_status', status)
FROM res;

-- =====================================================
-- ESTADO ACTUAL (para que el dashboard tenga datos "en vivo")
-- (fecha base 2026-01-25)
-- =====================================================
UPDATE parking_spot_state
SET status = 'FREE', updated_at = '2026-01-25 18:10:00'
WHERE spot_id IN (0,1,2,6,7);

UPDATE parking_spot_state
SET status = 'OCCUPIED', updated_at = '2026-01-25 18:10:00'
WHERE spot_id IN (3,5);


-- Sesiones abiertas (sin ended_at) para simular ocupación actual
INSERT INTO occupancy_sessions (spot_id, started_at, ended_at, duration_seconds, source)
VALUES
(3, '2026-01-25 18:00:00', NULL, NULL, 'VISION'),
(5, '2026-01-25 17:55:00', NULL, NULL, 'VISION');

COMMIT;
