import joblib
import os
from ultralytics import YOLO

# Load models
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FLOOD_MODEL_PATH = os.path.join(BASE_DIR, "models", "flood_model.pk1")
LANDSLIDE_MODEL_PATH = os.path.join(BASE_DIR, "models", "landslide_model.pkl")
YOLO_MODEL_PATH = os.path.join(BASE_DIR, "models", "yolo_model.pt")

_yolo_model = None

def load_flood_model():
    if os.path.exists(FLOOD_MODEL_PATH):
        return joblib.load(FLOOD_MODEL_PATH)
    raise FileNotFoundError(f"Flood model not found at {FLOOD_MODEL_PATH}")

def load_landslide_model():
    if os.path.exists(LANDSLIDE_MODEL_PATH):
        return joblib.load(LANDSLIDE_MODEL_PATH)
    raise FileNotFoundError(f"Landslide model not found at {LANDSLIDE_MODEL_PATH}")

def get_yolo_model():
    global _yolo_model
    if _yolo_model is None:
        if os.path.exists(YOLO_MODEL_PATH):
            _yolo_model = YOLO(YOLO_MODEL_PATH)
        else:
            # Fallback or specific error handling as per project needs
            # For now, we'll try to load it which might download if it's a known name, 
            # but the requirement says from the specific path.
            # If the path doesn't exist, we might want to log or raise.
            raise FileNotFoundError(f"YOLO model not found at {YOLO_MODEL_PATH}")
    return _yolo_model
