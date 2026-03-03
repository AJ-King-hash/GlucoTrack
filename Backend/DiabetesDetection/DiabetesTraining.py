import dataset.diabetesPandas as dp
import numpy as np
from BackPropagation import NeuralNetwork
# Dataset: XOR problem (inputs: 2 features, targets: 1 output)
inputs = np.array(dp.arr_inputs)
targets = np.array(dp.arr_targets)


# Create and train the network with two hidden layers: [input=2, hidden1=4, hidden2=3, output=1]
layers = [len(inputs[0]), 4, 3, len(targets)]
nn = NeuralNetwork(layers)
nn.train(inputs, targets, epochs=70000, learning_rate=0.1)
# Save the trained model
nn.save_model('DiabetesDetection/models/model.json')


# Demonstrate loading and using the model (e.g., for inference)
nn_loaded = NeuralNetwork(layers)  # Create with same layers
nn_loaded.load_model('DiabetesDetection/models/model.json')

# Test a new value (e.g., [0.5, 0.5] as a single sample)
test_input = np.array([[0, 0.5]])  # 2D array: (1 sample, 2 features)
prediction, _ = nn_loaded.forward(test_input)
print(f"Test Input: {test_input[0]}, Prediction: {prediction[0][0]:.4f}")

# Test multiple new values at once
test_inputs = np.array([[1, 1], [1.0, 0.0], [0.7, 0.3]])
predictions, _ = nn_loaded.forward(test_inputs)
print("Multiple Test Predictions:")
for input_val, pred in zip(test_inputs, predictions):
    print(f"Input: {input_val}, Prediction: {pred[0]:.4f}")