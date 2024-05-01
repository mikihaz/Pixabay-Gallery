// main.dart

import 'package:flutter/material.dart';
import 'package:pixabay_gallery/model/pixabay_api.dart';

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
  List<Hit> images = [];
  TextEditingController searchController = TextEditingController();
  late Future<PixabayResponse> response;

  @override
  void initState() {
    super.initState();
    _loadImages();
    searchController.addListener(_onSearchChanged);
    response = PixabayResponse.searchImages('nature');
    searchController.text = 'nature';
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _loadImages() async {
    // Fetch images from Pixabay API
    final query = searchController.text;
    final response = await PixabayResponse.searchImages(query);
    // Update _images list
    setState(() {
      images = response.hits;
    });
  }

  void _onSearchChanged() {
    // Implement debounce logic

    // Call _loadImages() with search query
    _loadImages();
  }

  void _openFullScreenImage(String imageUrl) {
    // Implement full-screen image display with animation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
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
            // onChanged: (value) {
            //   _onSearchChanged();
            // },
          ),
        ),
      ),
      body: FutureBuilder<PixabayResponse>(
          future: response,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null) {
              return const Center(child: Text('No images found'));
            } else {
              images = snapshot.data?.hits ?? [];
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      calculateColumnCount(MediaQuery.of(context).size.width),
                ),
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  return InkWell(
                    onTap: () {
                      _openFullScreenImage(image.largeImageURL ?? '');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              image.previewURL ?? '',
                              // change image size to fit the container

                              fit: BoxFit.cover,
                            ),
                          ),
                          Text('Likes: ${image.likes}'),
                          Text('Views: ${image.views}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }),
    );
  }

  int calculateColumnCount(double screenWidth) {
    // Calculate the number of columns based on screen width
    const int minWidth = 220;
    return (screenWidth / minWidth).floor();
  }
}
