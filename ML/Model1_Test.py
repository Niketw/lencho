import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image
import matplotlib.pyplot as plt

# ----------------------------
# 1. Load the Trained Model
# ----------------------------
model_path = './Models/Chili/Chili_disease_model.h5'  # Update with your model file
model = tf.keras.models.load_model(model_path)
print(f"✅ Model loaded successfully from: {model_path}")

# ----------------------------
# 2. Image Preprocessing Function
# ----------------------------
def load_and_preprocess_image(img_path, target_size=(299, 299)):
    """
    Loads an image, resizes it to `target_size`, and applies InceptionV3 preprocessing.
    """
    # Load the image
    img = image.load_img(img_path, target_size=target_size)
    
    # Convert the image to an array
    img_array = image.img_to_array(img)
    
    # Expand dimensions to match model input shape (1, 299, 299, 3)
    img_array = np.expand_dims(img_array, axis=0)
    
    # Normalize using InceptionV3 preprocessing (scales between [-1, 1])
    img_array = tf.keras.applications.inception_v3.preprocess_input(img_array)
    
    return img_array

# ----------------------------
# 3. Prediction Function
# ----------------------------
def predict_image_class(model, img_path, class_names=None):
    """
    Predicts the class of an image using the loaded model.
    """
    # Load and preprocess the image
    img_array = load_and_preprocess_image(img_path)

    # Get model predictions
    predictions = model.predict(img_array)
    
    # Find class with highest probability
    predicted_class_index = np.argmax(predictions, axis=1)[0]
    confidence = predictions[0][predicted_class_index]

    if class_names:
        predicted_class_label = class_names[predicted_class_index]
        print(f"🟢 Predicted Class: {predicted_class_label} with confidence {confidence:.4f}")
    else:
        print(f"🟢 Predicted Class Index: {predicted_class_index} with confidence {confidence:.4f}")
    
    return predicted_class_index, confidence

# ----------------------------
# 4. Example Usage
# ----------------------------
if __name__ == "__main__":
    # Update with your test image path
    image_path = "./images.jpg"

    # Provide class names (update based on your dataset)
    class_names = ['Chili__healthy', 'Chili__leaf curl', 'Chili__leaf spot', 'Chili__whitefly', 'Chili__yellowish']  # Update as needed

    # Predict the image class
    predict_image_class(model, image_path, class_names)

    # Display the image
    img_to_display = image.load_img(image_path, target_size=(299, 299))
    plt.imshow(img_to_display)
    plt.title("Test Image")
    plt.axis('off')
    plt.show()


#rice, pomegranate, lemon, jamun, gauva, coffee, Cassava  not trained properly

