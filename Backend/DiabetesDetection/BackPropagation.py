import numpy as np
import json
import os
def sigmoid(x):
    return 1 / (1 + np.exp(-x))

def sigmoid_deriv(x):
    return x * (1 - x)


class NeuralNetwork:
    def __init__(self, layers):
        self.layers = layers
        self.num_layers = len(layers)
        # Initialize weights and biases as lists
        self.weights = []
        self.biases = []
        for i in range(self.num_layers - 1):
            # Weights: shape (current_layer_size, next_layer_size)
            self.weights.append(np.random.rand(layers[i], layers[i + 1]))
            # Biases: shape (1, next_layer_size) for broadcasting
            self.biases.append(np.random.rand(1, layers[i + 1]))
    def forward(self, inputs):
        activations = [inputs]  # Start with input as first activation
        for i in range(self.num_layers - 1):
            # Compute next activation: sigmoid(dot(prev_activation, weights) + bias)
            next_activation = sigmoid(np.dot(activations[-1], self.weights[i]) + self.biases[i])
            activations.append(next_activation)
        return activations[-1], activations  # Return output and all activations
    
    def backpropagate(self, inputs, targets, output, activations, learning_rate):
        # Output layer delta
        output_error = output - targets
        deltas = [output_error * sigmoid_deriv(output)]  # Start with output delta
        
        # Backpropagate through hidden layers (reverse order)
        for i in range(self.num_layers - 2, 0, -1):  # From last hidden to first hidden
            error = np.dot(deltas[-1], self.weights[i].T)
            delta = error * sigmoid_deriv(activations[i])
            deltas.append(delta)
        
        deltas.reverse()  # Now deltas[0] is first hidden, etc.
        
        # Update weights and biases (starting from input to first hidden)
        for i in range(self.num_layers - 1):
            self.weights[i] -= learning_rate * np.dot(activations[i].T, deltas[i])
            self.biases[i] -= learning_rate * np.sum(deltas[i], axis=0, keepdims=True)
    
    def train(self, inputs, targets, epochs, learning_rate):
        for epoch in range(epochs):
            output, activations = self.forward(inputs)
            self.backpropagate(inputs, targets, output, activations, learning_rate)
            if epoch % 1000 == 0:
                loss = np.mean(np.square(targets - output))
                print(f"Epoch {epoch}, Loss={loss}")
    
    def save_model(self, filename='model.json'):
        """Save the model configuration and parameters to a JSON file."""
        data = {
            'layers': self.layers,
            'weights': [w.tolist() for w in self.weights],
            'biases': [b.tolist() for b in self.biases]
        }
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4)  # indent for readability
        print(f"Model saved to {filename}")
    
    def load_model(self, filename='model.json'):
        """Load the model configuration and parameters from a JSON file."""
        if not os.path.exists(filename):
            raise FileNotFoundError(f"Model file '{filename}' not found.")
        with open(filename, 'r') as f:
            data = json.load(f)
        
        # Validate layers match the instance's
        if data['layers'] != self.layers:
            raise ValueError("Loaded layers do not match the initialized model's layers.")
        
        # Reconstruct NumPy arrays
        self.weights = [np.array(w) for w in data['weights']]
        self.biases = [np.array(b) for b in data['biases']]
        self.num_layers = len(self.layers)  # Recompute for safety
        print(f"Model loaded from {filename}")
