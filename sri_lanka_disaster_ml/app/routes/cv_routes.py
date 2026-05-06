from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.cv_service import process_disaster_image
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

@router.post("/detect")
async def detect_disaster_features(file: UploadFile = File(...)):
    """
    Endpoint to upload an image and detect disaster-related features.
    """
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File provided is not an image.")
    
    try:
        contents = await file.read()
        results = process_disaster_image(contents)
        
        if "error" in results:
            raise HTTPException(status_code=500, detail=results["error"])
            
        return {
            "filename": file.filename,
            "analysis": results
        }
    except Exception as e:
        logger.error(f"Error in CV route: {e}")
        raise HTTPException(status_code=500, detail="Internal server error during image processing.")

@router.get("/info")
def get_cv_info():
    """
    Returns information about the CV capabilities.
    """
    return {
        "status": "active",
        "model": "YOLOv8 (placeholder)",
        "capabilities": ["object detection", "disaster feature identification"]
    }
