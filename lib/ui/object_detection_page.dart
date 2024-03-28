import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'grid.dart';

class ObjectDetectionPage extends StatefulWidget {
  final String username;
  final File imageFile;

  const ObjectDetectionPage({
    Key? key,
    required this.username,
    required this.imageFile,
  }) : super(key: key);

  @override
  _ObjectDetectionPageState createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  List<Map<String, dynamic>> yoloData = [];
  final String baseUrl = 'http://192.168.100.10:8000';

  @override
  void initState() {
    super.initState();
    _sendDataToYOLO(widget.username, widget.imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Object Detection"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Object Detection Page",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ImageWithBoundingBoxes(
                imageFile: widget.imageFile,
              ),
              if (yoloData.isNotEmpty)
                Column(
                  children: yoloData.map((box) {
                    return ElevatedButton(
                      onPressed: () {
                        _sendSearchRequest(box);
                      },
                      child: Text(box['label'].toString()),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendDataToYOLO(String username, File imageFile) async {
    final apiUrl = '$baseUrl/uploadImage/$username';
    print('Sending data: $username');

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields['name'] = username;
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Data sent successfully');
        final streamedResponse = await http.Response.fromStream(response);

        final Map<String, dynamic> data =
            json.decode(utf8.decode(streamedResponse.bodyBytes));
        final yoloOutputData = data['yolo output'];
        print('Yolo output data: $yoloOutputData');

        setState(() {
          yoloData = List<Map<String, dynamic>>.from(yoloOutputData);
        });
      } else {
        print('Failed to send data. Error code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending data: $error');
    }
  }

  Future<void> _sendSearchRequest(Map<String, dynamic> box) async {
    final apiUrl = '$baseUrl/search/';
    print('Sending search request for label: ${box['label']}');

    try {
      print('coordinates: ${box['coordinates']}');
      final List<int> coordinates = (box['coordinates'] as List<dynamic>)
          .map((value) => value as int)
          .toList();

      final Map<String, dynamic> requestData = {
        'coordinates': coordinates,
      };

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        print('Search request sent successfully');
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        final List<dynamic> results = jsonResponse['results'];

        print('send to ImageGridPage');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageGridPage(results: results),
          ),
        );
      } else {
        print(
            'Failed to send search request. Error code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending search request: $error');
    }
  }
}

class ImageWithBoundingBoxes extends StatelessWidget {
  final File imageFile;

  const ImageWithBoundingBoxes({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.file(imageFile),
        SizedBox(height: 10),
      ],
    );
  }
}
