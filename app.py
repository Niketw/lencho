from flask import Flask, request, jsonify
import joblib  # or import your ML framework

app = Flask(__name__)

# Load your ML model once when the application starts.
# Replace 'model.pkl' with the path to your model.
model = joblib.load('model.pkl')

@app.route('/')
def home():
    return "ML Model API is running!"

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Expecting a JSON payload with an 'input' key.
        data = request.get_json(force=True)
        input_features = data.get('input')
        if input_features is None:
            return jsonify({'error': 'No input provided'}), 400

        # Assuming the model expects a 2D array as input.
        prediction = model.predict([input_features])
        # Convert prediction to a list for JSON serialization.
        return jsonify({'prediction': prediction.tolist()})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # Run the Flask app on port 8080, which is the default for many cloud services.
    app.run(host='0.0.0.0', port=8080, debug=True)
