from fastapi import APIRouter
from src.db.db import get_api_connection

router = APIRouter()


@router.get("/")
def get_reservations():
    with get_api_connection() as conn:
        try:
            cur = conn.cursor()

            cur.execute("""
                SELECT
                    r.id,
                    d.full_name,
                    d.cedula,
                    r.spot_id,
                    r.status,
                    r.reserved_at,
                    r.expires_at
                FROM reservations r
                JOIN drivers d ON r.driver_id = d.id
                ORDER BY r.reserved_at DESC
            """)

            rows = cur.fetchall()

            return [
                {
                    "reservation_id": r["id"],
                    "driver": r["full_name"],
                    "cedula": r["cedula"],
                    "spot_id": r["spot_id"],
                    "status": r["status"],
                    "reserved_at": r["reserved_at"],
                    "expires_at": r["expires_at"]
                }
                for r in rows
            ]

        finally:
            conn.close()
