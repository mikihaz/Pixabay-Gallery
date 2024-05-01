// main.dart

import 'package:flutter/material.dart';
import 'package:pixabay_gallery/Screens/gallery_page.dart';

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



