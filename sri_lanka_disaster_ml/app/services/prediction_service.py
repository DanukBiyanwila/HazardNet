import numpy as np
import pandas as pd
from app.model_loader import load_flood_model, load_landslide_model
import logging

logger = logging.getLogger(__name__)

# Features used in the model
# latitude,longitude,elevation_m,distance_to_river_m,landcover,soil_type,population_density_per_km2,built_up_percent,urban_rural,rainfall_7d_mm,monthly_rainfall_mm,drainage_index,ndvi,ndwi,historical_flood_count,infrastructure_score
FLOOD_FEATURES = [
    "latitude", "longitude", "elevation_m", "distance_to_river_m", 
    "landcover", "soil_type", "population_density_per_km2", "built_up_percent", 
    "urban_rural", "rainfall_7d_mm", "monthly_rainfall_mm", "drainage_index", 
    "ndvi", "ndwi", "historical_flood_count", "infrastructure_score"
]

def predict_flood(input_data):
    logger.info(f"Predicting flood for data: {input_data}")
    
    try:
        model_data = load_flood_model()
        model = model_data['model']
        model_features = model_data['features']
        
        # Map input data to features
        features_dict = {col: 0 for col in model_features}
        
        # Direct mapping
        if "rainfall_7d_mm" in input_data:
            features_dict["rainfall_7d_mm"] = float(input_data["rainfall_7d_mm"])
        
        # Heuristic mapping for other features if possible
        if "river_level" in input_data:
            features_dict["distance_to_river_m"] = float(input_data["river_level"]) * 10 
            
        if "soil_moisture" in input_data:
            features_dict["drainage_index"] = float(input_data["soil_moisture"])
            
        # Build feature DataFrame
        X_df = pd.DataFrame([features_dict], columns=model_features)
        
        # Predict
        if hasattr(model, 'predict_proba'):
            probs = model.predict_proba(X_df)[0]
            probability = float(probs[1]) if len(probs) > 1 else float(probs[0])
            prediction = 1 if probability > 0.5 else 0
        else:
            prediction = int(model.predict(X_df)[0])
            probability = float(prediction)
            
    except Exception as e:
        logger.error(f"Error during flood prediction: {e}")
        prediction = 0
        probability = 0.0
        
    result = {
        "predicted_type": "FLOOD",
        "predicted_risk_level": "HIGH" if prediction == 1 or probability > 0.5 else "LOW",
        "confidence_score": round(probability, 4),
        "input_summary": input_data
    }
    
    logger.info(f"Flood prediction result: {result}")
    return result


def predict_landslide(input_data):
    logger.info(f"Predicting landslide for data: {input_data}")

    try:
        # Load the dictionary, then extract the actual model and features
        model_data = load_landslide_model()
        model = model_data['model']
        model_features = model_data['features']

        # Initialize all required features to 0
        features_dict = {col: 0 for col in model_features}

        # Map the input to our model's features
        # Support both flat input and hazardArea nested input
        if "rainfall_mm" in input_data:
            features_dict["AAP"] = float(input_data["rainfall_mm"])

        # Check for lat/lon in root or hazardArea
        if "location_lat" in input_data:
            features_dict["LAT"] = float(input_data["location_lat"])
        elif "hazardArea" in input_data and "location_lat" in input_data["hazardArea"]:
            features_dict["LAT"] = float(input_data["hazardArea"]["location_lat"])

        if "location_lon" in input_data:
            features_dict["LONG"] = float(input_data["location_lon"])
        elif "hazardArea" in input_data and "location_lon" in input_data["hazardArea"]:
            features_dict["LONG"] = float(input_data["hazardArea"]["location_lon"])

        # Build feature DataFrame in the EXACT order the model expects to avoid UserWarning
        X_df = pd.DataFrame([features_dict], columns=model_features)

        # Predict
        if hasattr(model, 'predict_proba'):
            probs = model.predict_proba(X_df)[0]
            probability = float(probs[1]) if len(probs) > 1 else float(probs[0])
            prediction = 1 if probability > 0.5 else 0
        else:
            prediction = int(model.predict(X_df)[0])
            probability = float(prediction)

    except Exception as e:
        logger.error(f"Error during landslide prediction: {e}")
        prediction = 0
        probability = 0.0

    result = {
        "predicted_type": "LANDSLIDE",
        "predicted_risk_level": "HIGH" if prediction == 1 or probability > 0.5 else "LOW",
        "confidence_score": round(probability, 4),
        "input_summary": input_data
    }

    logger.info(f"Landslide prediction result: {result}")
    return result