import os
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import joblib


def landslide_train_main():
    # Define paths
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    data_path = os.path.join(base_dir, 'processed_data', 'landslide_dataset_cleaned.csv')

    if not os.path.exists(data_path):
        print(f"Error: Dataset not found at {data_path}")
        return

    print(f"Loading dataset from: {data_path}")
    df = pd.read_csv(data_path)

    print("Class distribution:")
    print(df['Landslide'].value_counts())
    print("-" * 40)

    # Features and Target
    target_col = 'Landslide'
    # Get all columns EXCEPT the target
    features = [col for col in df.columns if col != target_col]

    X = df[features]
    y = df[target_col]

    # Split dataset
    print("Splitting dataset into train/test (80/20)...")
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Train Model
    print("Training Random Forest Classifier...")
    rf_model = RandomForestClassifier(n_estimators=100, class_weight='balanced', random_state=42, n_jobs=-1)
    rf_model.fit(X_train, y_train)

    # Output metrics
    y_pred = rf_model.predict(X_test)
    print("\n--- Model Evaluation ---")
    print(f"Accuracy: {accuracy_score(y_test, y_pred):.4f}\n")
    print("Classification Report:")
    print(classification_report(y_test, y_pred))

    # Save the trained model and features
    model_dir = os.path.join(base_dir, 'models')  # Matching your folder structure
    os.makedirs(model_dir, exist_ok=True)

    # NOTE: I am using .pkl here to match your folder structure README
    model_path = os.path.join(model_dir, 'landslide_model.pkl')

    model_data = {
        'model': rf_model,
        'features': features
    }

    joblib.dump(model_data, model_path)
    print(f"Model saved successfully to {model_path}.")


if __name__ == "__main__":
    landslide_train_main()