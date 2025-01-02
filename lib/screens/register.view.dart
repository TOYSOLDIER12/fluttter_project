import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _passVisible = false;
  String? _profileImage;

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Email is empty!';
    final emailPattern = r'^[^@]+@[^@]+\.[^@]+$';
    final regex = RegExp(emailPattern);
    if (!regex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _passValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password is empty!';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _confirmPassValidator(String? value) {
    if (value == null || value.isEmpty) return 'Confirm your password!';
    if (value != _passController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      final base64Image = base64Encode(bytes); // Convert to Base64
      setState(() {
        _profileImage = base64Image; // Store Base64 string
      });
    }
  }


  Future<String?> _uploadImage(String userId, String filePath) async {
    try {
      final ref = FirebaseStorage.instance.ref('profile_images/$userId.jpg');
      final uploadTask = ref.putFile(File(filePath));
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }


  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passController.text,
        );
        String? imageUrl;

        // If there's a profile image, upload it
        if (_profileImage != null) {
          final String userId = userCredential.user!.uid;
          final String filePath = _profileImage!;  // Path is the base64 string
          imageUrl = await _uploadImage(userId, filePath);
        }

        // Save user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text,
          'profileImage': imageUrl ?? _profileImage, // Use the Firebase Storage URL or base64 string
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration Successful!")),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration Failed: ${e.message}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register Page",
          style: Theme.of(context).textTheme.displayLarge,
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile picture
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? MemoryImage(base64Decode(_profileImage!)) // Convert Base64 back to image
                      : null,
                  child: _profileImage == null ? const Icon(Icons.add_a_photo, size: 50) : null,
                ),
              ),
              const SizedBox(height: 20),
              // Email input field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,
              ),
              const SizedBox(height: 20),
              // Password input field
              TextFormField(
                controller: _passController,
                obscureText: !_passVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passVisible = !_passVisible;
                      });
                    },
                  ),
                ),
                validator: _passValidator,
              ),
              const SizedBox(height: 20),
              // Confirm Password input field
              TextFormField(
                controller: _confirmPassController,
                obscureText: !_passVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passVisible = !_passVisible;
                      });
                    },
                  ),
                ),
                validator: _confirmPassValidator,
              ),
              const SizedBox(height: 30),
              // Register button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.all(15),
                ),
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}