import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  final String productName;
  final String productDescription;
  final double productPrice;

  const ImageSlider({
    Key? key,
    required this.imageUrls,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
  }) : super(key: key);

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final CarouselController _carouselController = CarouselController();
  int _current = 0;

  List<Widget> buildImageSliders() {
    return widget.imageUrls.map((url) {
      return Builder(
        builder: (BuildContext context) {
          return Image.network(url, fit: BoxFit.contain);
        },
      );
    }).toList();
  }

  List<Widget> buildIndicatorDots() {
    return widget.imageUrls.asMap().entries.map((entry) {
      return GestureDetector(
        onTap: () => _carouselController.animateToPage(entry.key),
        child: Container(
          width: 8.0,
          height: 8.0,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == entry.key ? Colors.blueAccent : Colors.grey),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          ("Product Details"),
          style: TextStyle(color: const Color.fromRGBO(0, 0, 0, 1)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CarouselSlider(
                  items: buildImageSliders(),
                  options: CarouselOptions(
                      autoPlay: false,
                      enlargeCenterPage: true,
                      aspectRatio: 1.0,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      }),
                  carouselController: _carouselController,
                ),
                Positioned(
                  left: 15,
                  child: GestureDetector(
                    onTap: () => _carouselController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear,
                    ),
                    child: Icon(Icons.arrow_back_ios,
                        size: 30, color: Colors.black54),
                  ),
                ),
                Positioned(
                  right: 15,
                  child: GestureDetector(
                    onTap: () => _carouselController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear,
                    ),
                    child: Icon(Icons.arrow_forward_ios,
                        size: 30, color: Colors.black54),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buildIndicatorDots(),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$${widget.productPrice}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.productDescription,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Add to cart functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color.fromARGB(255, 59, 173, 215), // Button color
                        foregroundColor: Colors.white, // Text color
                      ),
                      child: Text('Add to Cart'),
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
