import 'package:flutter/material.dart';
import 'ImageSlider.dart';

// DetailedImageView widget
class DetailedImageView extends StatelessWidget {
  final String imageUrl;
  final String label;

  const DetailedImageView({
    Key? key,
    required this.imageUrl,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detailed View'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ImageGridPage widget
class ImageGridPage extends StatelessWidget {
  final List<dynamic> results;

  const ImageGridPage({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Grid"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: results.length,
          itemBuilder: (BuildContext context, int index) {
            final Map<String, dynamic> imageDetails = results[index];
            final String imageUrl = imageDetails['url'];
            final String label = imageDetails['Product_Name'];
            final String productDescription = imageDetails['Product_Description'];

            return GestureDetector(
              onTap: () {
                // Extract image URLs from the DataFrame entry
                List<String> imageUrls =
                    List<String>.from(imageDetails['URLs']);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ImageSlider(
                      imageUrls: imageUrls,
                      productName:
                          label, // Use `productName` instead of `label`
                      productDescription:
                         productDescription, // Add a description or fetch it similar to label
                      productPrice: 29.99 // Set a default or fetch price
                      ),
                ));
              },
              child: Hero(
                tag: imageUrl,
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            label,
                            style:
                                Theme.of(context).textTheme.subtitle1?.copyWith(
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
      ),
    );
  }
}
