import cv2
import numpy as np
from PIL import Image
from app.model_loader import get_yolo_model
import logging
import io

logger = logging.getLogger(__name__)

def detect_objects_in_image(image_bytes):
    """
    Detects objects in an image using YOLOv8.
    """
    try:
        model = get_yolo_model()
        if model is None:
            return {"error": "Model not loaded"}

        # Convert bytes to PIL Image
        img = Image.open(io.BytesIO(image_bytes))
        
        # Run inference
        results = model(img)
        
        detections = []
        for result in results:
            boxes = result.boxes
            for box in boxes:
                # Get coordinates, confidence, and class
                x1, y1, x2, y2 = box.xyxy[0].tolist()
                conf = float(box.conf[0])
                cls = int(box.cls[0])
                name = model.names[cls]
                
                detections.append({
                    "bbox": [x1, y1, x2, y2],
                    "confidence": round(conf, 4),
                    "class": name
                })
        
        return {
            "detections": detections,
            "count": len(detections)
        }
    except Exception as e:
        logger.error(f"Error during object detection: {e}")
        return {"error": str(e)}

def process_disaster_image(image_bytes):
    """
    Specific logic for disaster-related image analysis.
    For now, it uses general object detection as a base.
    """
    # This is where you would add logic to specifically identify 
    # floods, landslides, or damaged infrastructure.
    results = detect_objects_in_image(image_bytes)
    
    # Placeholder: if we see 'water' or similar classes, we might flag it (if the model supports it)
    # Since yolov8n is general, we just return the detections for now.
    return results
