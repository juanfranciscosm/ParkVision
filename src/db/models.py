from datetime import datetime
from .db import get_connection

# ---------------- ESTADO ACTUAL ----------------
def get_estado(plaza_id):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(
        "SELECT ocupada FROM estado_actual WHERE plaza_id = ?",
        (plaza_id,)
    )
    estado = cur.fetchone()[0]
    conn.close()
    return bool(estado)


def update_estado(plaza_id, ocupada):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(
        """
        UPDATE estado_actual
        SET ocupada = ?, last_update = ?
        WHERE plaza_id = ?
        """,
        (int(ocupada), datetime.now(), plaza_id)
    )
    conn.commit()
    conn.close()


# ---------------- SESIONES ----------------
def iniciar_sesion(plaza_id):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(
        """
        INSERT INTO sesiones (plaza_id, inicio)
        VALUES (?, ?)
        """,
        (plaza_id, datetime.now())
    )
    conn.commit()
    conn.close()


def cerrar_sesion(plaza_id):
    conn = get_connection()
    cur = conn.cursor()

    # Última sesión abierta
    cur.execute(
        """
        SELECT id, inicio FROM sesiones
        WHERE plaza_id = ? AND fin IS NULL
        ORDER BY inicio DESC LIMIT 1
        """,
        (plaza_id,)
    )
    row = cur.fetchone()

    if row:
        sesion_id, inicio = row
        fin = datetime.now()
        duracion = int((fin - datetime.fromisoformat(inicio)).total_seconds())

        cur.execute(
            """
            UPDATE sesiones
            SET fin = ?, duracion_segundos = ?
            WHERE id = ?
            """,
            (fin, duracion, sesion_id)
        )

    conn.commit()
    conn.close()
