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
          crossAxisCount: 2, // Set the number of columns in the grid
          crossAxisSpacing: 8.0, // Set the spacing between columns
          mainAxisSpacing: 8.0, // Set the spacing between rows
        ),
        itemCount: results.length,
        itemBuilder: (BuildContext context, int index) {
          // Extract image details from the results
          final Map<String, dynamic> imageDetails = results[index];
          final String imageUrl = imageDetails['url'];

          return GestureDetector(
            onTap: () {
              // Handle image tap (if needed)
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
