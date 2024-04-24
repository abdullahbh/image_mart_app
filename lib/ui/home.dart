import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_flutter/ui/image_veiwer.dart';
import 'login.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final Box _boxLogin = Hive.box("login");
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
        builder: (_) =>
            ImageViewerScreen(imagePath: _capturedImagePath ?? "")));
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            color: Colors
                .black, // Set the background color for the entire container
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.camera_alt, color: Colors.white),
                  title: Text('Capture Image',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _captureImage();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: Colors.white),
                  title: Text('Pick from Gallery',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
              ],
            ),
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
          _categoryIcon(Icons.event_seat, 'Chairs', 'assets/chair.jpeg'),
          _categoryIcon(Icons.bed, 'Cabinets', 'assets/cabinet.jpeg'),
          _categoryIcon(Icons.table_bar, 'Tables', 'assets/table.jpeg'),
          _categoryIcon(Icons.weekend, 'Sofas', 'assets/sofa.jpeg'),
          _categoryIcon(Icons.bed, 'Beds', 'assets/bed.jpeg'),
          _categoryIcon(Icons.bed, 'Lamp', 'assets/lamp.jpeg'),
        ],
      ),
      floatingActionButton: Container(
        height: 80.0, // Adjust the size by setting height
        width: 80.0, // Adjust the size by setting width
        child: FloatingActionButton(
          onPressed: _showImageSourceActionSheet,
          tooltip: 'Scan',
          backgroundColor: Colors.black,
          child: Icon(
            Icons.camera_enhance,
            color: Colors.white,
            size: 40.0, // Increase the icon size
          ),
          elevation: 10.0, // Adds shadow to make the button stand out
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0) // More rounded shape
              ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        color: Color(0xFF6ACBEA), // Setting the color of the BottomAppBar
        child: Row(
          // Adding the icons to the BottomAppBar
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.home, color: Colors.white), onPressed: () {}),
            IconButton(
              icon: Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryIcon(IconData icon, String label, String imagePath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          imagePath,
          width: 170,
          height: 170,
        ),
        Text(label),
      ],
    );
  }
}
