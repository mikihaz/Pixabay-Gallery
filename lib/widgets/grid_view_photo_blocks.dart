import 'package:flutter/material.dart';
import 'package:pixabay_gallery/model/pixabay_api.dart';

class GridViewPhotoBlocks extends StatelessWidget {
  const GridViewPhotoBlocks({
    super.key,
    required this.image,
  });

  final Hit image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.hardEdge,
          child: AspectRatio(
            aspectRatio: 1,
            child: FutureBuilder<String>(
              // Replace 'highQualityImageUrl' with the URL of your high quality image
              future: precacheImage(
                      NetworkImage(image.largeImageURL ?? ''), context)
                  .then((_) => image.largeImageURL ?? ''),
              builder: (context, snapshot) {
                return Image.network(
                  // If the high quality image is loaded, display it. Otherwise, display the low quality image
                  snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData
                      ? snapshot.data ?? ''
                      : image.previewURL ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      image.likes.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.remove_red_eye,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      image.views.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
