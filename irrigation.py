import pandas as pd
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import load_model
import joblib


def predict_water_requirement(input_data: dict) -> float:
    """
    Predicts the water requirement based on input values provided as a dictionary (or JSON).

    Expected keys in the dictionary:
        "CROP TYPE", "SOIL TYPE", "REGION", "TEMPERATURE", "WEATHER CONDITION"

    For example:
        {
            "CROP TYPE": "WHEAT",
            "SOIL TYPE": "DRY",
            "REGION": "DESERT",
            "TEMPERATURE": "20-30",
            "WEATHER CONDITION": "SUNNY"
        }

    Returns:
        float: Predicted water requirement (in the original scale).
    """
    # Define the required keys
    required_keys = ["CROP TYPE", "SOIL TYPE", "REGION", "TEMPERATURE", "WEATHER CONDITION"]

    # Verify that all required keys are present in the input dictionary
    missing_keys = [key for key in required_keys if key not in input_data]
    if missing_keys:
        raise ValueError(f"Missing keys in input: {missing_keys}")

    # Convert the dictionary into a one-row DataFrame
    input_df = pd.DataFrame([input_data])

    # One-hot encode categorical features (using drop_first=False)
    input_encoded = pd.get_dummies(input_df, drop_first=False)

    # Reindex the encoded DataFrame to ensure it has the same columns as the training data.
    # The list of training columns is saved in 'training_columns.pkl'
    training_columns = joblib.load("./ML/Irrigation/training_columns.pkl")
    input_encoded = input_encoded.reindex(columns=training_columns, fill_value=0)

    # Load the pre-fitted scaler and standardize the features
    scaler = joblib.load("./ML/Irrigation/scaler.pkl")
    input_scaled = scaler.transform(input_encoded)

    # Load the trained model (with custom objects as needed)
    custom_objects = {"mse": tf.keras.metrics.MeanSquaredError()}
    model = load_model("./ML/Irrigation/final_nn_model.h5", custom_objects=custom_objects)

    # Make the prediction (model output is in log scale)
    y_pred_log = model.predict(input_scaled).flatten()

    # Convert prediction back to the original scale
    y_pred = np.expm1(y_pred_log)

    return y_pred[0]
