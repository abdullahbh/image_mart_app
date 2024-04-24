import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'grid.dart';
import 'dart:ui' as ui;

class ImageViewerScreen extends StatefulWidget {
  final String imagePath;

  const ImageViewerScreen({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  _ImageViewerScreenState createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  List<Map<String, dynamic>> yoloData = [];
  final String baseUrl = 'http://172.16.52.193:8000';

  ui.Image? image; // Image object to hold the loaded image

  @override
  void initState() {
    super.initState();
    _loadImage(File(widget.imagePath)); // Load the image on init
    _sendDataToYOLO(File(widget.imagePath));
  }

  // New method to load the image and get its dimensions
  Future<void> _loadImage(File imageFile) async {
    final data = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    setState(() {
      image = frame.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Object Detection"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Object Detection Page",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (image != null) // Ensure the image object is loaded
                FittedBox(
                  child: SizedBox(
                    width: image!.width.toDouble(),
                    height: image!.height.toDouble(),
                    child: Stack(
                      children: [
                        Image.file(File(widget.imagePath)),
                        CustomPaint(
                          size: Size(image!.width.toDouble(),
                              image!.height.toDouble()),
                          painter: BoundingBoxPainter(yoloData, image!),
                        ),
                        ..._createDotButtons(),
                      ],
                    ),
                  ),
                ),
              // Button widgets moved outside of FittedBox and into their own Column
              if (yoloData.isNotEmpty)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Wrap(
                    direction: Axis.horizontal,
                    children: yoloData.map((box) {
                      return ElevatedButton(
                        onPressed: () => _sendSearchRequest(box),
                        child: Text(box['label'].toString()),
                      );
                    }).toList(),
                  ),
                ),
              ElevatedButton(
                onPressed: _cropImage,
                child: const Text("Crop Image"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _createDotButtons() {
    List<Widget> dotButtons = [];
    if (image == null) return dotButtons;

    double scaleX = MediaQuery.of(context).size.width / image!.width;
    double scaleY = MediaQuery.of(context).size.width /
        image!.height; // Maintain aspect ratio

    for (var data in yoloData) {
      final coordinates = data['coordinates'];
      final double centerX = (coordinates[0] + coordinates[2]) / 2 * scaleX;
      final double centerY = (coordinates[1] + coordinates[3]) / 2 * scaleY;

      dotButtons.add(
        Positioned(
          left: centerX - 25, // Adjust these values as needed for accuracy
          top: centerY - 25,
          child: GestureDetector(
            onTap: () => _sendSearchRequest(data),
            child: Container(
              width: 250, // Size of the touch area
              height: 250,
              color: Colors.transparent,
            ),
          ),
        ),
      );
    }

    return dotButtons;
  }

  Future<void> _sendDataToYOLO(File imageFile) async {
    final String apiUrl = '$baseUrl/uploadImage/';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ));

      var response = await request.send();
      if (response.statusCode == 200) {
        print('Data sent successfully');
        final streamedResponse = await http.Response.fromStream(response);
        final data = json.decode(utf8.decode(streamedResponse.bodyBytes));
        setState(() {
          yoloData = List<Map<String, dynamic>>.from(data['yolo output']);
        });
      } else {
        print('Failed to send data. Error code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending data: $e');
    }
  }

  Future<void> _sendSearchRequest(Map<String, dynamic> box) async {
    final String apiUrl = '$baseUrl/search/';
    print("Sending search request for box: $box"); // Debug print

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'coordinates': box['coordinates']}),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ImageGridPage(results: jsonResponse['results']),
          ),
        );
      } else {
        print(
            'Failed to send search request. Error code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending search request: $e');
    }
  }

  Future<void> _cropImage() async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: widget.imagePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );

    if (croppedImage != null) {
      await _sendDataToAPI(context, croppedImage.path);
      print('Cropped image path: ${croppedImage.path}');
    }
  }

  Future<void> _sendDataToAPI(BuildContext context, String imagePath) async {
    final String apiUrl = '$baseUrl/searchCropped/';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Data sent successfully');

        var streamedResponse = await http.Response.fromStream(response);
        final Map<String, dynamic> jsonResponse =
            json.decode(utf8.decode(streamedResponse.bodyBytes));
        final List<dynamic> results = jsonResponse['results'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageGridPage(results: results),
          ),
        );
      } else {
        print('Failed to send data. Error code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending data: $error');
    }
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> yoloData;
  final ui.Image image;

  BoundingBoxPainter(this.yoloData, this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / image.width;
    final double scaleY = size.height / image.height;
    final paintBox = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.fill;

    for (var data in yoloData) {
      final List<dynamic> coordinates = data['coordinates'];
      final Rect rect = Rect.fromLTRB(
        coordinates[0].toDouble() * scaleX,
        coordinates[1].toDouble() * scaleY,
        coordinates[2].toDouble() * scaleX,
        coordinates[3].toDouble() * scaleY,
      );
      canvas.drawRect(rect, paintBox);

      // Draw dot at the center of the bounding box
      final Offset center = Offset(
        (rect.left + rect.right) / 2,
        (rect.top + rect.bottom) / 2,
      );
      canvas.drawCircle(center, 13.0, paintDot); // Radius of 5.0 for the dot
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
