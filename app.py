from flask import Flask, request, jsonify
import joblib
from irrigation import predict_water_requirement

app = Flask(__name__)

# Load your ML model once when the application starts.
# Replace 'model.pkl' with the path to your model.
model = joblib.load('model.pkl')

@app.route('/')
def home():
    return "ML Model API is running!"

@app.route('/predict_irrigation', methods=['POST'])
def predict_irrigation():
    try:
        # Expect JSON input containing the required keys
        # Check irrigation.py for required keys
        data = request.get_json(force=True)
        prediction = predict_water_requirement(data)
        return jsonify({"predicted_water_requirement": prediction})
    except Exception as e:
        return jsonify({"error": str(e)}), 400


if __name__ == '__main__':
    # Run the Flask app on port 8080, which is the default for many cloud services.
    app.run(host='0.0.0.0', port=8080, debug=True)
