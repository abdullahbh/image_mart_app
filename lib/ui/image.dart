// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:http/http.dart' as http;
// import 'grid.dart'; // Ensure this import points to your actual grid view file.

// class ImageViewerScreen extends StatefulWidget {
//   final String imagePath;

//   const ImageViewerScreen({
//     Key? key,
//     required this.imagePath,
//   }) : super(key: key);

//   @override
//   _ImageViewerScreenState createState() => _ImageViewerScreenState();
// }

// class _ImageViewerScreenState extends State<ImageViewerScreen> {
//   static const String baseUrl = 'http://172.17.23.100:8000';
//   List<Map<String, dynamic>> yoloData = [];

//   @override
//   void initState() {
//     super.initState();
//     _sendDataToYOLO(File(widget.imagePath));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Object Detection"),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 "Object Detection Page",
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               Image.file(File(widget.imagePath)),
//               if (yoloData.isNotEmpty)
//                 Column(
//                   children: yoloData.map((box) {
//                     return ElevatedButton(
//                       onPressed: () => _sendSearchRequest(box),
//                       child: Text(box['label'].toString()),
//                     );
//                   }).toList(),
//                 ),
//               ElevatedButton(
//                 onPressed: _cropImage,
//                 child: const Text("Crop Image"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _sendDataToYOLO(File imageFile) async {
//     final String apiUrl = '$baseUrl/uploadImage/';
//     print('Sending data');

//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
//         ..files.add(await http.MultipartFile.fromPath(
//           'image',
//           imageFile.path,
//         ));

//       var response = await request.send();
//       if (response.statusCode == 200) {
//         print('Data sent successfully');
//         final streamedResponse = await http.Response.fromStream(response);
//         final data = json.decode(utf8.decode(streamedResponse.bodyBytes));
//         setState(() {
//           yoloData = List<Map<String, dynamic>>.from(data['yolo output']);
//         });
//       } else {
//         print('Failed to send data. Error code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error sending data: $e');
//     }
//   }

//   Future<void> _sendSearchRequest(Map<String, dynamic> box) async {
//     final String apiUrl = '$baseUrl/search/';
//     print('Sending search request for label: ${box['label']}');

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'coordinates': box['coordinates']}),
//       );
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 ImageGridPage(results: jsonResponse['results']),
//           ),
//         );
//       } else {
//         print(
//             'Failed to send search request. Error code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error sending search request: $e');
//     }
//   }

//   Future<void> _cropImage() async {
//     final croppedImage = await ImageCropper().cropImage(
//       sourcePath: widget.imagePath,
//       aspectRatioPresets: [
//         CropAspectRatioPreset.square,
//         CropAspectRatioPreset.ratio3x2,
//         CropAspectRatioPreset.original,
//         CropAspectRatioPreset.ratio4x3,
//         CropAspectRatioPreset.ratio16x9,
//       ],
//       uiSettings: [
//         AndroidUiSettings(
//           toolbarTitle: 'Cropper',
//           toolbarColor: Colors.deepOrange,
//           toolbarWidgetColor: Colors.white,
//           initAspectRatio: CropAspectRatioPreset.original,
//           lockAspectRatio: false,
//         ),
//         IOSUiSettings(
//           title: 'Cropper',
//         ),
//       ],
//     );

//     if (croppedImage != null) {
//       // Send the cropped image to the FastAPI endpoint
//       await _sendDataToAPI(context, croppedImage.path);
//       print('Cropped image path: ${croppedImage.path}');
//     }
//   }

//   Future<void> _sendDataToAPI(BuildContext context, String imagePath) async {
//     final apiUrl = '$baseUrl/searchCropped/';

//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'image',
//           imagePath,
//         ),
//       );

//       var response = await request.send();

//       if (response.statusCode == 200) {
//         print('Data sent successfully');

//         var streamedResponse = await http.Response.fromStream(response);
//         final Map<String, dynamic> jsonResponse =
//             json.decode(utf8.decode(streamedResponse.bodyBytes));
//         final List<dynamic> results = jsonResponse['results'];

//         print('Results: $results');

//         // Navigate to ImageGridPage and pass the results
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ImageGridPage(results: results),
//           ),
//         );
//       } else {
//         print('Failed to send data. Error code: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error sending data: $error');
//     }
//   }
// }
