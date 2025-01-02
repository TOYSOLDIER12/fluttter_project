import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:tflite/tflite.dart';
import '../model_runner.dart';
import 'image_selection_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? _base64Image;
  bool _isLoading = true;
  final ModelRunner _modelRunner = ModelRunner();

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
  }

  Future<void> _fetchProfileImage() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final snapshot = await FirebaseDatabase.instance.ref('users/$uid').get();
        final data = snapshot.value as Map?;
        if (data != null && data['profileImage'] != null) {
          setState(() {
            _base64Image = data['profileImage'];
          });
        }
      }
    } catch (e) {
      print("Error fetching profile image: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runModel(String modelPath, String imagePath) async {
    if (_base64Image != null) {
      final results = await _modelRunner.runModelOnImage(modelPath, imagePath);
      print(results);
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: _base64Image != null ? MemoryImage(base64Decode(_base64Image!)) : null,
                    child: _base64Image == null ? Icon(Icons.person) : null,
                  ),
                  const SizedBox(width: 10),
                  Text(user.email ?? 'No Email'),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildModelSection('LSTM', 'Long Short-Term Memory', 'assets/lstm_model.tflite'),
            const SizedBox(height: 20),
            _buildModelSection('CNN', 'Convolutional Neural Network', 'assets/cnn_model.tflite'),
            const SizedBox(height: 20),
            _buildModelSection('ANN', 'Artificial Neural Network', 'assets/ann_model.tflite'),
          ],
        ),
      ),
    );
  }

  Widget _buildModelSection(String title, String description, String modelPath) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // Navigate to Image Selection Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageSelectionScreen(modelPath: modelPath),
                  ),
                );
              },
              child: Text('Run $title Model'),
            ),
          ],
        ),
      ),
    );
  }
}
