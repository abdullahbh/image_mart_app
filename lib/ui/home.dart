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
        _navigateToImageViewer();
      });
    }
  }

  void _navigateToImageViewer() {
    // Implement navigation to image viewer page with the image path.
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ImageViewerScreen(imagePath: _capturedImagePath ?? "" )));
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Capture Image'),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pick from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // Implement menu action if needed
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[
          _categoryIcon(Icons.star, 'Popular'),
          _categoryIcon(Icons.event_seat, 'Chairs'),
          _categoryIcon(Icons.table_bar, 'Tables'),
          _categoryIcon(Icons.weekend, 'Sofas'),
          _categoryIcon(Icons.bed, 'Beds'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImageSourceActionSheet,
        tooltip: 'Scan',
        child: Icon(Icons.camera_enhance),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(icon: Icon(Icons.home), onPressed: () {}),
            IconButton(icon: Icon(Icons.account_circle), onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => Login()));}),
          ],
        ),
      ),
    );
  }

  Widget _categoryIcon(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 50),
        Text(label),
      ],
    );
  }
}