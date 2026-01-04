from fastapi import APIRouter
from src.db.db import get_api_connection

router = APIRouter()


@router.get("/occupancy")
def occupancy_summary():
    with get_api_connection() as conn: 
        try:
            cur = conn.cursor()

            cur.execute("""
                SELECT
                    status,
                    COUNT(*) as count
                FROM parking_spot_state
                GROUP BY status
            """)

            rows = cur.fetchall()

            return {
                row["status"]: row["count"]
                for row in rows
            }

        finally:
            conn.close()  
