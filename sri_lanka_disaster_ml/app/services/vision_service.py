import cv2
import numpy as np
from app.model_loader import get_yolo_model
from app.utils.image_utils import bytes_to_cv2
import logging

logger = logging.getLogger(__name__)

def count_people_in_image(image_bytes: bytes) -> int:
    """
    Analyzes an image and returns the total count of detected persons.
    
    Args:
        image_bytes: Raw bytes of the image file.
        
    Returns:
        int: Total number of people detected.
    """
    try:
        # Load the singleton YOLO model
        model = get_yolo_model()
        
        # Convert bytes to OpenCV format (numpy array) using utility
        cv_image = bytes_to_cv2(image_bytes)
        
        if cv_image is None:
            return 0
        
        # Run inference
        # classes=[0] filters results to only "person" class in COCO dataset
        results = model.predict(cv_image, classes=[0], verbose=False)
        
        # Calculate total count from results
        person_count = 0
        for result in results:
            if hasattr(result, 'boxes'):
                person_count += len(result.boxes)
                
        logger.info(f"Person detection complete. Count: {person_count}")
        return person_count

    except Exception as e:
        logger.error(f"Error during person counting: {e}")
        # Return 0 or raise depending on desired error policy. 
        # For a service, returning 0 and logging is often safer.
        return 0
