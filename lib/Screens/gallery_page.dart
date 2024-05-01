import 'package:flutter/material.dart';
import 'package:pixabay_gallery/model/pixabay_api.dart';
import 'package:pixabay_gallery/widgets/grid_view_photo_blocks.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<Hit> images = [];
  TextEditingController searchController = TextEditingController();
  late Future<PixabayResponse> response;
  int isHoveringId = -1;
  bool isSearchClicked = false;
  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
    searchController.addListener(_onSearchChanged);
    scrollController.addListener(loadMoreImages);
    response = PixabayResponse.searchImages('');
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _loadImages() async {
    // Fetch images from Pixabay API
    final query = searchController.text;
    // Update _images list
    setState(() {
      response = PixabayResponse.searchImages(query);
    });
  }

  void _onSearchChanged() {
    // Call _loadImages()
    _loadImages();
  }

  void _openFullScreenImage(String imageUrl) {
    // Implement full-screen image display with animation
  }

  void loadMoreImages() async {
    // Implement infinite scrolling
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      // Load more images
      final PixabayResponse response = await PixabayResponse.searchImages(
          searchController.text,
          page: currentPage + 1);
      setState(() {
        images.addAll(response.hits);
        currentPage++;
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pixabay Gallery'),
        actions: [
          isSearchClicked
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      isSearchClicked = false;
                    });
                  },
                )
              : InkWell(
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search),
                        if (searchController.text.isNotEmpty)
                          const SizedBox(width: 4),
                        Text(searchController.text),
                      ],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      isSearchClicked = true;
                    });
                    // Focus on search field
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
          if (isSearchClicked)
            Container(
              margin: const EdgeInsets.only(
                right: 8,
                top: 8,
                bottom: 8,
              ),
              padding: const EdgeInsets.all(8),
              height: 40,
              width: 300,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search images',
                  // no border
                  border: InputBorder.none,
                ),
                // align text to center
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
        ],
      ),
      body: FutureBuilder<PixabayResponse>(
          future: response,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null) {
              return const Center(
                  child: Text('No images found',
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)));
            } else {
              images = snapshot.data?.hits ?? [];
              return Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: calculateColumnCount(
                            MediaQuery.of(context).size.width),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final image = images[index];
                        return InkWell(
                          focusColor: Colors.transparent,
                          // hoverColor: Colors.black.withOpacity(0.5),
                          onTap: () {
                            _openFullScreenImage(image.largeImageURL ?? '');
                          },
                          // onHover: (isHovering) {
                          //   // Implement hover effect
                          //   setState(() {
                          //     isHoveringId = isHovering ? (image.id ?? -1) : -1;
                          //   });
                          // },
                          child: Container(
                            // padding: const EdgeInsets.all(8),
                            // margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // border: Border.all(
                              //   color: isHoveringId == image.id
                              //       ? Colors.grey
                              //       : Colors.transparent,
                              //   width: 1,
                              // ),
                              borderRadius: BorderRadius.circular(8),
                              // boxShadow: [
                              //   isHoveringId == image.id
                              //       ? BoxShadow(
                              //           color: Colors.grey[300] ??
                              //               Colors.transparent,
                              //           blurRadius: 2,
                              //           spreadRadius: 5,
                              //         )
                              //       : const BoxShadow(
                              //           color: Colors.transparent),
                              // ],
                            ),
                            child: GridViewPhotoBlocks(image: image),
                          ),
                        );
                      },
                    ),
                  ),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      ),
                    ),
                ],
              );
            }
          }),
      // floating button to scroll to top
      // show only when user scrolls down and scroll controller is attached to a scroll view
      floatingActionButton: (scrollController.hasClients)
          ? (scrollController.position.pixels > 0)
              ? FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: () {
                    scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                )
              : null
          : null,
    );
  }

  int calculateColumnCount(double screenWidth) {
    // Calculate the number of columns based on screen width
    const int minWidth = 220;
    return (screenWidth / minWidth).floor();
  }
}
