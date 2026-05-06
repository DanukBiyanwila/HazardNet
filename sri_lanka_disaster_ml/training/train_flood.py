import os
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import joblib
from sklearn.metrics import roc_auc_score

def flood_train_main():
    # Define paths
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    data_path = os.path.join(base_dir, 'processed_data', 'flood_dataset_cleaned.csv')
    
    # Check if data exists
    if not os.path.exists(data_path):
        print(f"Error: Dataset not found at {data_path}")
        return


    print(f"Loading dataset from: {data_path}")
    df = pd.read_csv(data_path)

    print("Class distribution:")
    print(df['flood_occurrence_current_event'].value_counts())
    print("-" * 40)


    # Features and Target
    target_col = 'flood_occurrence_current_event'
    features = [
        'latitude', 'longitude', 'elevation_m', 'distance_to_river_m', 
        'landcover', 'soil_type', 'population_density_per_km2', 
        'built_up_percent', 'urban_rural', 'rainfall_7d_mm', 
        'monthly_rainfall_mm', 'drainage_index', 'ndvi', 'ndwi', 
        'historical_flood_count', 'infrastructure_score'
    ]
    
    X = df[features]
    y = df[target_col]

    # Split dataset into train/test (80/20)
    print("Splitting dataset into train/test (80/20)...")
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Train Random Forest Classifier
    print("Training Random Forest Classifier...")
    rf_model = RandomForestClassifier(
    n_estimators=100,
    class_weight='balanced',
    random_state=42,
    n_jobs=-1
    )
    rf_model.fit(X_train, y_train)

    # Output metrics
    y_pred = rf_model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    if len(y_test.unique()) > 1:
        roc_auc = roc_auc_score(y_test, rf_model.predict_proba(X_test)[:, 1])
        print(f"ROC AUC Score: {roc_auc:.4f}")
    else:
        print("ROC AUC cannot be calculated (only one class present).")
    conf_matrix = confusion_matrix(y_test, y_pred)
    class_report = classification_report(y_test, y_pred)

    print("\n--- Model Evaluation ---")
    print(f"Accuracy: {accuracy:.4f}\n")
    print("Confusion Matrix:")
    print(f"{conf_matrix}\n")
    print("Classification Report:")
    print(class_report)

    # Save the trained model
    model_dir = os.path.join(base_dir, 'model')
    os.makedirs(model_dir, exist_ok=True)
    
    # Handle the project structure 'models/' as well
    models_dir = os.path.join(base_dir, 'models')
    os.makedirs(models_dir, exist_ok=True)

    model_path_1 = os.path.join(model_dir, 'flood_model.pk1')
    model_path_2 = os.path.join(models_dir, 'flood_model.pk1')
    
    print(f"Saving model with features to {model_path_1} ...")
    
    # Save the model pipeline or dict to preserve feature names for prediction
    model_data = {
        'model': rf_model,
        'features': features
    }
    
    joblib.dump(model_data, model_path_1)
    # Saving to both model/ and models/ dirs to accommodate the structure vs request
    joblib.dump(model_data, model_path_2) 
    
    print("Model saved successfully.")

if __name__ == "__main__":
    flood_train_main()
