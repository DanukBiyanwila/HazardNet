import cv2
import numpy as np
import logging

logger = logging.getLogger(__name__)

def bytes_to_cv2(image_bytes: bytes) -> np.ndarray:
    """
    Converts raw image bytes into an OpenCV BGR image (numpy array).
    
    Args:
        image_bytes: Raw bytes of the image file.
        
    Returns:
        np.ndarray: The decoded OpenCV image, or None if decoding fails.
    """
    try:
        # Convert bytes to a 1D numpy array of type uint8
        nparr = np.frombuffer(image_bytes, np.uint8)
        
        # Decode the image array into an OpenCV BGR image
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            logger.error("Failed to decode image: imdecode returned None.")
            
        return img
    except Exception as e:
        logger.error(f"Error converting image bytes to OpenCV format: {e}")
        return None
