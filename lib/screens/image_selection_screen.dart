import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';
import 'dart:convert';  // For base64 decoding
import 'package:flutter/foundation.dart';  // To detect platform
import '../model_runner.dart';

class ImageSelectionScreen extends StatefulWidget {
  final String modelPath;

  const ImageSelectionScreen({super.key, required this.modelPath});

  @override
  _ImageSelectionScreenState createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  File? _imageFile;
  String? _base64Image;
  final ImagePicker _picker = ImagePicker();
  final ModelRunner _modelRunner = ModelRunner();


  @override
  void initState() {
    super.initState();
    _loadModel();
  }
  Future<void> _loadModel() async {
    await _modelRunner.loadModel(widget.modelPath);
  }

  // Pick an image from gallery (local/mobile)
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _base64Image = null;  // Reset base64Image
      });
    }
  }

  // Take a photo using the camera (local/mobile)
  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _base64Image = null;  // Reset base64Image
      });
    }
  }

  // Select an image from the web (base64 format)
  Future<void> _selectImageFromWeb(String base64Image) async {
    setState(() {
      _base64Image = base64Image;
      _imageFile = null;  // Reset local image file
    });
  }

  // Run the model on the selected image
  Future<void> _runModel() async {
    if (_imageFile != null) {
      final results = await _modelRunner.runModelOnImage(widget.modelPath, _imageFile!.path);
      print(results);  // You can display the results here
    } else if (_base64Image != null) {
      final results = await _modelRunner.runModelOnImage(widget.modelPath, _base64Image!);
      print(results);  // You can display the results here
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No image selected!')));
    }
  }

  // Display image or base64Image for web
  Widget _buildImageDisplay() {
    if (_imageFile != null) {
      return Image.file(_imageFile!, width: 150, height: 150);
    } else {
      return SizedBox.shrink();  // Empty if no image selected
    }
  }

  // Platform detection for web or mobile
  bool get isWeb => kIsWeb;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Image'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImageDisplay(),  // Display selected image or base64 image
            const SizedBox(height: 20),
            // Show different options based on the platform
            if (!isWeb) ...[
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image from Gallery'),
              ),
              ElevatedButton(
                onPressed: _takePhoto,
                child: Text('Take Photo with Camera'),
              ),
            ],
            if (isWeb) ...[
              ElevatedButton(
                onPressed: () {
                  // Example of selecting a base64 image from web
                  _selectImageFromWeb('your_base64_image_string_here');
                },
                child: Text('Select Image from Web (Base64)'),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _runModel,
              child: Text('Run Model'),
            ),
          ],
        ),
      ),
    );
  }
}
