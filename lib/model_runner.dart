import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class ModelRunner {
  bool _isModelLoaded = false;

  Future<void> loadModel(String modelPath) async {
    if (!_isModelLoaded) {
      await Tflite.loadModel(model: modelPath);
      _isModelLoaded = true;
    }
  }

  Future<List?> runModelOnImage(String modelPath, String imagePath) async {
    if (!_isModelLoaded) {
      // Load the model before running
      await loadModel(modelPath);
    }
    return await Tflite.runModelOnImage(path: imagePath); // Change depending on what your model expects
  }
}
