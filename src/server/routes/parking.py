from fastapi import APIRouter
from src.db.db import get_api_connection

router = APIRouter()


@router.get("/")
def get_parkings():
    with get_api_connection() as conn:
        cur = conn.cursor()

        cur.execute("""
            SELECT id, name, address, total_spots
            FROM parkings
        """)

        rows = cur.fetchall()
        conn.close()

    return [
        {
            "id": r[0],
            "name": r[1],
            "address": r[2],
            "total_spots": r[3]
        }
        for r in rows
    ]
