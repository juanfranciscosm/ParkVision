from fastapi import APIRouter, HTTPException
from src.db.db import get_api_connection

router = APIRouter()


@router.get("/")
def get_all_spots():
    """
    Devuelve todas las plazas con su estado actual
    """
    with get_api_connection() as conn:
        try:
            cur = conn.cursor()

            cur.execute("""
                SELECT 
                    ps.id            AS spot_id,
                    ps.code          AS code,
                    pss.status       AS status,
                    pss.updated_at   AS updated_at
                FROM parking_spots ps
                JOIN parking_spot_state pss ON ps.id = pss.spot_id
                ORDER BY ps.id
            """)

            rows = cur.fetchall()

            return [
                {
                    "spot_id": row["spot_id"],
                    "code": row["code"],
                    "status": row["status"],
                    "updated_at": row["updated_at"]
                }
                for row in rows
            ]

        finally:
            conn.close()  


@router.get("/{spot_id}")
def get_spot(spot_id: int):
    """
    Devuelve el estado de una plaza específica
    """
    with get_api_connection() as conn:
        try:
            cur = conn.cursor()

            cur.execute("""
                SELECT 
                    status,
                    updated_at
                FROM parking_spot_state
                WHERE spot_id = ?
            """, (spot_id,))

            row = cur.fetchone()

            if row is None:
                raise HTTPException(
                    status_code=404,
                    detail="Plaza no encontrada"
                )

            return {
                "spot_id": spot_id,
                "status": row["status"],
                "updated_at": row["updated_at"]
            }

        finally:
            conn.close()   