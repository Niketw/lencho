import os
import csv
import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image
import matplotlib.pyplot as plt


#[Cherry healthy, Chilli yellowish, Jamun healthy, Pomegranate_healthy] has bad test data, ignore
#


# ----------------------------
# 1. Image Preprocessing Function
# ----------------------------
def load_and_preprocess_image(img_path, target_size=(299, 299)):
    """
    Loads an image, resizes it to `target_size`, and applies InceptionV3 preprocessing.
    """
    try:
        img = image.load_img(img_path, target_size=target_size)
    except Exception as e:
        print(f"Error loading image {img_path}: {e}")
        raise

    # Convert the image to an array
    img_array = image.img_to_array(img)

    # Expand dimensions to match model input shape (1, target_size[0], target_size[1], 3)
    img_array = np.expand_dims(img_array, axis=0)

    # Normalize using InceptionV3 preprocessing (scales between [-1, 1])
    img_array = tf.keras.applications.inception_v3.preprocess_input(img_array)

    return img_array


# ----------------------------
# 2. Prediction Function
# ----------------------------
def predict_image_class(model, img_path, class_names=None):
    """
    Predicts the class of an image using the loaded model.
    Returns the predicted class label and its confidence.
    """
    # Load and preprocess the image
    img_array = load_and_preprocess_image(img_path)

    # Get model predictions
    predictions = model.predict(img_array)
    # Debug: Print the predictions shape and values
    print(f"DEBUG: predictions for '{img_path}' have shape {predictions.shape} and values: {predictions}")

    # Check that predictions are not empty
    if predictions.size == 0:
        raise ValueError(f"No predictions were returned for image {img_path}")

    try:
        predicted_class_index = np.argmax(predictions, axis=1)[0]
    except Exception as e:
        print(f"❌ Error getting argmax for predictions: {e}")
        raise

    # Debug: Print the predicted class index
    print(f"DEBUG: predicted_class_index = {predicted_class_index}")

    # If class_names is provided, ensure it has enough entries.
    if class_names:
        if predicted_class_index >= len(class_names):
            print(
                f"⚠️ Warning: predicted_class_index ({predicted_class_index}) is out of range for class_names (length {len(class_names)}).")
            predicted_class_label = "Unknown"
        else:
            predicted_class_label = class_names[predicted_class_index]
    else:
        predicted_class_label = str(predicted_class_index)

    # Also extract the confidence value from the predictions.
    try:
        confidence = predictions[0][predicted_class_index]
    except Exception as e:
        print(f"❌ Error accessing confidence value: {e}")
        raise

    return predicted_class_label, confidence


# ----------------------------
# 3. Main Automation Script
# ----------------------------
def main():
    # Define the root directories for models and dataset images.
    models_root = "./Models"
    dataset_root = "./dataset"  # Note: adjust this if needed (e.g., capital D)

    # List all plant directories in the Models folder.
    plant_dirs = [d for d in os.listdir(models_root) if os.path.isdir(os.path.join(models_root, d))]

    # This will store the per-disease accuracy results for output.
    results = []

    for plant in plant_dirs:
        print(f"\n🔍 Processing plant: {plant}")

        # Define paths for the model and classes file.
        plant_model_folder = os.path.join(models_root, plant)
        model_filename = f"{plant}_disease_model.h5"
        class_filename = f"{plant}_classes.txt"
        model_path = os.path.join(plant_model_folder, model_filename)
        class_path = os.path.join(plant_model_folder, class_filename)

        # Verify that model and classes files exist.
        if not os.path.exists(model_path):
            print(f"⚠️ Model file not found for plant '{plant}' at: {model_path}. Skipping.")
            continue
        if not os.path.exists(class_path):
            print(f"⚠️ Classes file not found for plant '{plant}' at: {class_path}. Skipping.")
            continue

        # Load the trained model.
        try:
            model = tf.keras.models.load_model(model_path)
            print(f"✅ Loaded model from: {model_path}")
        except Exception as e:
            print(f"❌ Error loading model for plant '{plant}': {e}")
            continue

        # Read class names from the classes file (assuming one class per line).
        try:
            with open(class_path, "r") as f:
                class_names = [line.strip() for line in f if line.strip()]
            if not class_names:
                print(f"⚠️ No class names found in {class_path}.")
        except Exception as e:
            print(f"❌ Error reading classes file for plant '{plant}': {e}")
            continue

        # For the current plant, find all disease folders in the dataset folder.
        # These folders are assumed to be named in the format: "<plant>__<diseaseName>"
        disease_folders = [d for d in os.listdir(dataset_root)
                           if os.path.isdir(os.path.join(dataset_root, d)) and d.startswith(plant + "__")]
        if not disease_folders:
            print(f"⚠️ No disease subfolders found for plant '{plant}' in the dataset.")
            continue

        for disease in disease_folders:
            disease_folder_path = os.path.join(dataset_root, disease)

            # Get all image files (assuming .jpg, .jpeg, .png).
            image_files = [f for f in os.listdir(disease_folder_path)
                           if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
            if not image_files:
                print(f"⚠️ No image files found in {disease_folder_path}. Skipping this disease folder.")
                continue

            # Extract the disease name from the folder name.
            # Expected folder name format: "<plant>__<diseaseName>"
            disease_name = disease.split("__", 1)[1] if "__" in disease else disease

            total_count = 0
            correct_count = 0

            # Process every image file in the disease folder.
            for img_file in image_files:
                image_path = os.path.join(disease_folder_path, img_file)
                try:
                    predicted_label, confidence = predict_image_class(model, image_path, class_names)
                    total_count += 1
                    # A prediction is considered correct if the disease name is found in the predicted label.
                    if disease_name.lower() in predicted_label.lower():
                        correct_count += 1
                    print(f"🟢 [Plant: {plant} | Disease: {disease}] File: {img_file} -> Predicted: {predicted_label} (Confidence: {confidence:.4f})")
                except Exception as e:
                    print(f"❌ Error during prediction for image {img_file} in disease folder '{disease}': {e}")
                    continue

            # Calculate accuracy for this disease folder.
            accuracy = correct_count / total_count if total_count > 0 else 0
            print(f"📊 [Plant: {plant} | Disease: {disease}] Accuracy: {accuracy:.4f} ({correct_count}/{total_count})")
            results.append({
                "plant": plant,
                "disease_folder": disease,
                "disease_name": disease_name,
                "accuracy": accuracy
            })

    # ----------------------------
    # 4. Save Results to CSV
    # ----------------------------
    csv_filename = "results.csv"
    try:
        with open(csv_filename, "w", newline="") as csvfile:
            writer = csv.writer(csvfile)
            # Write header row.
            writer.writerow(["Plant__Disease", "Accuracy"])
            for res in results:
                plant_disease = f"{res['plant']}__{res['disease_name']}"
                writer.writerow([plant_disease, res['accuracy']])
        print(f"\n✅ Results have been saved to {csv_filename}")
    except Exception as e:
        print(f"❌ Error writing to CSV file: {e}")


if __name__ == "__main__":
    main()

