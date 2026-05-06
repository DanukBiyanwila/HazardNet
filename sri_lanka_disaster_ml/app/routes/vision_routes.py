from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.vision_service import count_people_in_image
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

@router.post("/count-people")
async def count_people(file: UploadFile = File(...)):
    """
    Endpoint to upload an image and count the number of people detected.
    """
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File provided is not an image.")
    
    try:
        contents = await file.read()
        count = count_people_in_image(contents)
        
        return {
            "people_count": count
        }
    except Exception as e:
        logger.error(f"Error in vision route: {e}")
        raise HTTPException(status_code=500, detail="Internal server error during image processing.")

@router.get("/info")
def get_vision_info():
    """
    Returns information about the vision service capabilities.
    """
    return {
        "status": "active",
        "service": "People Counting",
        "model": "YOLO (COCO Class 0)"
    }
