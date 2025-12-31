INSERT INTO plazas (id, nombre) VALUES
(0, 'P0'),
(1, 'P1'),
(2, 'P2'),
(3, 'P3'),
(4, 'P4'),
(5, 'P5'),
(6, 'P6'),
(7, 'P7'),
(8, 'P8'),
(9, 'P9'),
(10, 'P10'),
(11, 'P11');

INSERT INTO estado_actual (plaza_id, ocupada, last_update)
SELECT id, 0, CURRENT_TIMESTAMP FROM plazas;
