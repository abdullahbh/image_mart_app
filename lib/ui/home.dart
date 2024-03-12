import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_flutter/ui/image_veiwer.dart';
import 'object_detection_page.dart';

import 'login.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Box _boxLogin = Hive.box("login");
  String? _capturedImagePath;

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _capturedImagePath = pickedFile.path;
        _navigateToImageViewer();
      });
    }
  }

  Future<void> _captureImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _capturedImagePath = pickedFile.path;
        _navigateToObjectDetection();
      });
    }
  }

  void _navigateToObjectDetection() {
    String username = _boxLogin.get("userName") ?? "";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ObjectDetectionPage(
          username: username,
          imageFile: File(_capturedImagePath!),
        ),
      ),
    );
  }

  void _navigateToImageViewer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(imagePath: _capturedImagePath!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Picker App"),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              child: IconButton(
                onPressed: () {
                  _boxLogin.clear();
                  _boxLogin.put("loginStatus", false);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Login();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.logout_rounded),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome 🎉",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _boxLogin.get("userName") ?? "",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImageFromGallery,
              child: Text("Pick Image from Gallery"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _captureImage,
              child: Text("Capture Image"),
            ),
            const SizedBox(height: 20),
            if (_capturedImagePath != null)
              GestureDetector(
                onTap: () {
                  // Open the captured image on click
                  _openImage(_capturedImagePath!);
                },
                child: Image.file(
                  File(_capturedImagePath!),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ElevatedButton(
              onPressed: () {
                // Handle case when no image is selected
                if (_capturedImagePath == null) {
                  // You can show a snackbar or dialog to inform the user.
                  return;
                }

                _navigateToObjectDetection();
              },
              child: Text("Search"),
            ),
          ],
        ),
      ),
    );
  }

  void _openImage(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(imagePath: imagePath),
      ),
    );
  }
}
