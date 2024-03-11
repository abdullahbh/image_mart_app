import 'package:flutter/material.dart';

class ImageGridPage extends StatelessWidget {
  final List<dynamic> results;

  const ImageGridPage({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Grid"),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: results.length,
        itemBuilder: (BuildContext context, int index) {
          final Map<String, dynamic> imageDetails = results[index];
          final String imageUrl = imageDetails['url'];
          final String label = imageDetails['label'];

          return GestureDetector(
            onTap: () {
              // Navigate to a detailed view or implement further actions on image tap
            },
            child: Hero(
              tag: imageUrl, // Unique tag for each image to enable Hero animation
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
