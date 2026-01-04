import json
from datetime import datetime
from src.db.db import get_connection



# --------------------------------------------------
# ESTADO ACTUAL DE UNA PLAZA
# --------------------------------------------------
def get_estado(spot_id: int) -> str | None:
    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        "SELECT status FROM parking_spot_state WHERE spot_id = ?",
        (spot_id,)
    )
    row = cur.fetchone()
    
    conn.commit()

    return row["status"] if row else None


def update_estado(spot_id: int, nuevo_estado: str):
    """
    nuevo_estado: FREE | RESERVED | OCCUPIED
    """
    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        """
        UPDATE parking_spot_state
        SET status = ?, updated_at = CURRENT_TIMESTAMP
        WHERE spot_id = ?
        """,
        (nuevo_estado, spot_id)
    )

    conn.commit()


# --------------------------------------------------
# SESIONES DE OCUPACIÓN
# --------------------------------------------------
def iniciar_sesion(spot_id: int, source: str = "VISION"):
    """
    Inicia sesión SOLO si no existe una abierta
    """
    conn = get_connection()
    cur = conn.cursor()

    # ¿ya existe sesión abierta?
    cur.execute(
        """
        SELECT id FROM occupancy_sessions
        WHERE spot_id = ? AND ended_at IS NULL
        """,
        (spot_id,)
    )

    if cur.fetchone() is None:
        cur.execute(
            """
            INSERT INTO occupancy_sessions (spot_id, started_at, source)
            VALUES (?, ?, ?)
            """,
            (spot_id, datetime.utcnow(), source)
        )

        registrar_evento(spot_id, "OCCUPIED", {"source": source})

    conn.commit()


def cerrar_sesion(spot_id: int):
    """
    Cierra la sesión activa y calcula duración
    """
    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        """
        SELECT id, started_at FROM occupancy_sessions
        WHERE spot_id = ? AND ended_at IS NULL
        """,
        (spot_id,)
    )

    row = cur.fetchone()
    if row:
        started_at = datetime.fromisoformat(row["started_at"])
        ended_at = datetime.utcnow()
        duration = int((ended_at - started_at).total_seconds())

        cur.execute(
            """
            UPDATE occupancy_sessions
            SET ended_at = ?, duration_seconds = ?
            WHERE id = ?
            """,
            (ended_at, duration, row["id"])
        )

        registrar_evento(spot_id, "FREED", {"duration": duration})

    conn.commit()


# --------------------------------------------------
# EVENTOS (AUDITORÍA)
# --------------------------------------------------
def registrar_evento(spot_id, event_type, metadata=None):
    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        """
        INSERT INTO events (spot_id, event_type, metadata)
        VALUES (?, ?, ?)
        """,
        (spot_id, event_type, json.dumps(metadata) if metadata else None)
    )

    conn.commit()

# --------------------------------------------------
# RESERVAS (base)
# --------------------------------------------------
def crear_reserva(spot_id: int, driver_id: int, qr_code: str, expires_at: datetime):
    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        """
        INSERT INTO reservations (
            spot_id, driver_id, qr_code,
            reserved_at, expires_at, status
        )
        VALUES (?, ?, ?, ?, ?, 'ACTIVE')
        """,
        (spot_id, driver_id, qr_code, datetime.utcnow(), expires_at)
    )

    update_estado(spot_id, "RESERVED")
    registrar_evento(spot_id, "RESERVED", {"driver_id": driver_id})

    conn.commit()


def confirmar_reserva(qr_code: str):
    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        """
        SELECT id, spot_id FROM reservations
        WHERE qr_code = ? AND status = 'ACTIVE'
        """,
        (qr_code,)
    )
    row = cur.fetchone()
    if row:
        cur.execute(
            """
            UPDATE reservations
            SET confirmed_at = ?, status = 'CONFIRMED'
            WHERE id = ?
            """,
            (datetime.utcnow(), row["id"])
        )

        update_estado(row["spot_id"], "OCCUPIED")
        iniciar_sesion(row["spot_id"], source="QR")
        registrar_evento(row["spot_id"], "CONFIRMED", {"qr": qr_code})

    conn.commit()


# --------------------------------------------------
# CONSULTAS ANALÍTICAS (ejemplos)
# --------------------------------------------------
def plazas_ocupadas(parking_id: int) -> int:
    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        """
        SELECT COUNT(*) FROM parking_spot_state s
        JOIN parking_spots ps ON s.spot_id = ps.id
        WHERE ps.parking_id = ? AND s.status = 'OCCUPIED'
        """,
        (parking_id,)
    )

    count = cur.fetchone()[0]

    conn.commit()

    return count


def tiempo_promedio_por_plaza(spot_id: int) -> float:
    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        """
        SELECT AVG(duration_seconds)
        FROM occupancy_sessions
        WHERE spot_id = ? AND duration_seconds IS NOT NULL
        """,
        (spot_id,)
    )

    avg = cur.fetchone()[0]
    
    conn.commit()

    return avg if avg else 0.0
