from fastapi import FastAPI
from src.server.routes import parking, spots, stats, reservations

app = FastAPI(
    title="ParkVision API",
    description="API para monitoreo inteligente de estacionamientos",
    version="1.0.0"
)

app.include_router(parking.router, prefix="/parkings", tags=["Parkings"])
app.include_router(spots.router, prefix="/spots", tags=["Parking Spots"])
app.include_router(reservations.router, prefix="/reservations", tags=["Reservations"])
app.include_router(stats.router, prefix="/stats", tags=["Analytics"])


@app.get("/")
def root():
    return {
        "message": "🚗 ParkVision API funcionando",
        "status": "OK"
    }
