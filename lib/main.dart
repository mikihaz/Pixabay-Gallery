// main.dart

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixabay Gallery',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const GalleryPage(),
    );
  }
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<Map<String, dynamic>> images = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadImages();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _loadImages() async {
    // Fetch images from Pixabay API
    // Update _images list
  }

  void _onSearchChanged() {
    // Implement debounce logic
    // Call _loadImages() with search query
  }

  void _openFullScreenImage(String imageUrl) {
    // Implement full-screen image display with animation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                searchController.clear();
              },
            ),
          ),
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              _calculateColumnCount(MediaQuery.of(context).size.width),
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final image = images[index];
          return GestureDetector(
            onTap: () {
              _openFullScreenImage(image['largeImageURL']);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(image['previewURL']),
                Text('Likes: ${image['likes']}'),
                Text('Views: ${image['views']}'),
              ],
            ),
          );
        },
      ),
    );
  }

  int _calculateColumnCount(double screenWidth) {
    // Calculate the number of columns based on screen width
  }
}
