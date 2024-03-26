import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'grid.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imagePath;
  final baseUrl = 'http://172.17.23.13:8000';

  const ImageViewerScreen({Key? key, required this.imagePath})
      : super(key: key);

  Future<void> _cropImage(BuildContext context) async {
    ImageCropper imageCropper =
        ImageCropper(); // Create an instance of ImageCropper
    CroppedFile? croppedImage = await imageCropper.cropImage(
      sourcePath: File(imagePath).path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );

    if (croppedImage != null) {
      // Send the cropped image to the FastAPI endpoint
      await _sendDataToAPI(context, croppedImage.path);
      print('Cropped image path: ${croppedImage.path}');
    }
  }

  Future<void> _sendDataToAPI(BuildContext context, String imagePath) async {
    final apiUrl = '$baseUrl/searchCropped/';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Content-Type'] = 'multipart/form-data';
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Data sent successfully');

        // Read the response body as a stream
        var streamedResponse = await http.Response.fromStream(response);

        final Map<String, dynamic> jsonResponse =
            json.decode(utf8.decode(streamedResponse.bodyBytes));

        final List<dynamic> results = jsonResponse['results'];

        print('Results:');
        print(results);

        // Navigate to ImageGridPage and pass the results
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Viewer"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(
              File(imagePath),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _cropImage(context),
                    child: Row(
                      children: [
                        Icon(Icons.crop),
                        SizedBox(width: 8.0),
                        Text("Crop Image"),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _sendDataToAPI(context, imagePath),
                    child: Row(
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 8.0),
                        Text("Search Image"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
