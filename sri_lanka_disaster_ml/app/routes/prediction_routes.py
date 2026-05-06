from fastapi import APIRouter
from app.services.prediction_service import predict_flood, predict_landslide

router = APIRouter()

@router.post("/flood")
def flood_prediction(data: dict):
    return predict_flood(data)

@router.get("/flood")
def test_flood_get():
    return {"message": "Flood prediction endpoint is active. Use POST to send data."}

# NEW ENDPOINT FOR LANDSLIDE
@router.post("/landslide")
def landslide_prediction(data: dict):
    return predict_landslide(data)

@router.get("/landslide")
def test_landslide_get():
    return {"message": "Landslide prediction endpoint is active. Use POST to send data."}