import pandas as pd
import numpy as np
from sklearn.preprocessing import LabelEncoder
from pathlib import Path
import joblib

def clean_flood_dataset():
    # Define paths using pathlib to be relative to the project structure
    base_dir = Path(__file__).resolve().parent.parent.parent
    input_path = base_dir / 'training' / 'flood_dataset.csv'
    output_path = base_dir / 'processed_data' / 'flood_dataset_cleaned.csv'
    
    # Read the dataset
    df = pd.read_csv(input_path)
    
    # 1. Keep ONLY the required columns
    required_cols = [
        'latitude', 'longitude', 'elevation_m', 'distance_to_river_m',
        'landcover', 'soil_type', 'population_density_per_km2',
        'built_up_percent', 'urban_rural', 'rainfall_7d_mm',
        'monthly_rainfall_mm', 'drainage_index', 'ndvi', 'ndwi',
        'historical_flood_count', 'infrastructure_score',
        'flood_occurrence_current_event'
    ]
    df = df[required_cols]
    
    # 2. Remove duplicate rows
    df = df.drop_duplicates()
    
    # 3. Drop rows with missing values in required columns
    df = df.dropna(subset=required_cols)
    
    # 4. Strip whitespace from categorical columns
    categorical_cols = ['landcover', 'soil_type', 'urban_rural']
    for col in categorical_cols:
        # Only apply string operations on object/string typed columns
        if df[col].dtype == 'object':
            df[col] = df[col].astype(str).str.strip()
            
    # 5. Convert numeric columns to proper numeric types
    numeric_cols = [
        'latitude', 'longitude', 'elevation_m', 'distance_to_river_m',
        'population_density_per_km2', 'built_up_percent', 'rainfall_7d_mm',
        'monthly_rainfall_mm', 'drainage_index', 'ndvi', 'ndwi',
        'historical_flood_count', 'infrastructure_score'
    ]
    for col in numeric_cols:
        df[col] = pd.to_numeric(df[col], errors='coerce')
        
    df = df.dropna(subset=numeric_cols)
    
    # 6. Encode categorical columns using Label Encoding
    le = LabelEncoder()
    for col in categorical_cols:
        df[col] = le.fit_transform(df[col])
        
    # 7. Properly encode flood occurrence (Yes=1, No=0)
    df['flood_occurrence_current_event'] = (
        df['flood_occurrence_current_event']
            .astype(str)
            .str.strip()
            .str.lower()
            .map({'yes': 1, 'no': 0})
    )

    # Drop rows where mapping failed
    df = df.dropna(subset=['flood_occurrence_current_event'])

    df['flood_occurrence_current_event'] = df['flood_occurrence_current_event'].astype(int)
    
    # 8. Reset index
    df = df.reset_index(drop=True)
    
    # Ensure processed_data directory exists just in case
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    # 9. Save cleaned dataset
    df.to_csv(output_path, index=False)
    
    print(f"Flood dataset cleaned and saved to {output_path}")
    return df


import pandas as pd
import numpy as np
from pathlib import Path


def clean_landslide_dataset():
    base_dir = Path(__file__).resolve().parent.parent.parent
    input_path = base_dir / 'training' / 'landslide_dataset.csv'
    output_path = base_dir / 'processed_data' / 'landslide_dataset_cleaned.csv'

    df = pd.read_csv(input_path)

    df = df.rename(columns={
        "AAP(mm)": "AAP",
        "RiverDIST(m)": "RiverDIST",
        "FaultDIST(m)": "FaultDIST",
        "Slop(Percent)": "SlopePercent",
        "Slop(Degrees)": "SlopeDegrees"
    })

    df["Landslide"] = 1

    # WARNING: This synthetic data generation should be replaced with real non-landslide data ASAP!
    df_non = df.copy()
    if "Elevation" in df_non.columns:
        df_non["Elevation"] *= np.random.uniform(0.8, 1.2, len(df_non))
    if "SlopePercent" in df_non.columns:
        df_non["SlopePercent"] *= np.random.uniform(0.5, 1.0, len(df_non))

    # Randomize coordinates slightly so they aren't EXACTLY the same place
    df_non["LAT"] += np.random.uniform(-0.01, 0.01, len(df_non))
    df_non["LONG"] += np.random.uniform(-0.01, 0.01, len(df_non))

    df_non["Landslide"] = 0

    df = pd.concat([df, df_non], ignore_index=True)

    drop_cols = ["ID", "DES_GEOUNI", "DES_ClimateType"]
    df = df.drop(columns=[c for col in drop_cols if (c := col) in df.columns])

    df = df.fillna(df.median(numeric_only=True))
    df = df.fillna("unknown")

    categorical_cols = ["SUB_Basin", "Landuse_Type", "GEO_UNIT", "Climate_Type"]
    df = pd.get_dummies(
        df,
        columns=[c for col in categorical_cols if (c := col) in df.columns]
    )

    # Boolean columns to integers (True/False -> 1/0)
    for col in df.columns:
        if df[col].dtype == bool:
            df[col] = df[col].astype(int)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output_path, index=False)

    print(f"Landslide dataset cleaned and saved to {output_path}")
    return df

if __name__ == "__main__":
    print("Starting preprocessing...")
    try:
        clean_flood_dataset()
    except Exception as e:
        print(f"Error cleaning flood dataset: {e}")
        
    try:
        clean_landslide_dataset()
    except Exception as e:
        print(f"Error cleaning landslide dataset: {e}")
        
    print("Preprocessing complete.")
