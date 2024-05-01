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
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  late Future<PixabayResponse> response;
  int isHoveringId = -1;
  bool isSearchClicked = false;
  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  bool isLoading = false;
  Widget? floatingActionButton;

  @override
  void initState() {
    super.initState();
    loadImages();
    searchController.addListener(onSearchChanged);
    scrollController.addListener(loadMoreImages);
    scrollController.addListener(buildFloatingActionButton);
    response = PixabayResponse.searchImages('');
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void loadImages() async {
    // Fetch images from Pixabay API
    final query = searchController.text;
    // Update _images list
    setState(() {
      searchQuery = query;
      response = PixabayResponse.searchImages(query);
    });
  }

  void onSearchChanged() {
    // check if the user has new input
    if (searchController.text == searchQuery) {
      return;
    }
    // Call _loadImages()
    loadImages();
  }

  void openFullScreenImage(Hit image) {
    // Implement full-screen image display with animation
    // open a dialog with the image
    showDialog(
      context: context,
      builder: (contextDialog) {
        Hit localImage = images.firstWhere((element) => element.id == image.id);
        int index = images.indexOf(localImage);
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  // width: MediaQuery.of(context).size.width * 0.6,
                  // height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black,
                    // image: DecorationImage(
                    //   image: NetworkImage(localImage.largeImageURL ?? ''),
                    //   fit: BoxFit.contain,
                    // ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: FutureBuilder<String>(
                    future: precacheImage(
                            NetworkImage(localImage.largeImageURL ?? ''),
                            context)
                        .then((_) => localImage.largeImageURL ?? ''),
                    builder: (context, snapshot) {
                      return Hero(
                        tag: 'imageHero${localImage.id}',
                        child: InteractiveViewer(
                          trackpadScrollCausesScale: true,
                          child: Image.network(
                            snapshot.connectionState == ConnectionState.done &&
                                    snapshot.hasData
                                ? snapshot.data ?? ''
                                : localImage.previewURL ?? '',
                            width: double.infinity,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // close button
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Image details
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
                        // Previous button
                        if (index > 0)
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white),
                            onPressed: () {
                              if (index > 0) {
                                setState(() {
                                  localImage = images[index - 1];
                                  index--;
                                });
                              }
                            },
                          ),
                        // Likes
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              localImage.likes.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        // Views
                        Row(
                          children: [
                            const Icon(
                              Icons.remove_red_eye,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              localImage.views.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        // Comments
                        Row(
                          children: [
                            const Icon(
                              Icons.comment,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              localImage.comments.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        // Downloads
                        Row(
                          children: [
                            const Icon(
                              Icons.download,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              localImage.downloads.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        // Next button
                        if (index < images.length - 1)
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios,
                                color: Colors.white),
                            onPressed: () {
                              if (index < images.length - 1) {
                                setState(() {
                                  localImage = images[index + 1];
                                  index++;
                                });
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                // User details
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage:
                              NetworkImage(localImage.userImageURL ?? ''),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          localImage.user ?? 'Unknown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Next button
                // if (index < images.length - 1)
                //   Positioned(
                //     right: 5,
                //     bottom: 0,
                //     child: IconButton(
                //       icon: const Icon(Icons.arrow_forward_ios,
                //           color: Colors.white),
                //       onPressed: () {
                //         if (index < images.length - 1) {
                //           setState(() {
                //             localImage = images[index + 1];
                //             index++;
                //           });
                //         }
                //       },
                //     ),
                //   ),
                // Previous button
                // if (index > 0)
                //   Positioned(
                //     left: 5,
                //     bottom: 0,
                //     child: IconButton(
                //       icon:
                //           const Icon(Icons.arrow_back_ios, color: Colors.white),
                //       onPressed: () {
                //         if (index > 0) {
                //           setState(() {
                //             localImage = images[index - 1];
                //             index--;
                //           });
                //         }
                //       },
                //     ),
                //   ),
              ],
            ),
          );
        });
      },
    );
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
            if (snapshot.connectionState == ConnectionState.waiting) {
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
                            openFullScreenImage(image);
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
      floatingActionButton: floatingActionButton,
    );
  }

  int calculateColumnCount(double screenWidth) {
    // Calculate the number of columns based on screen width
    const int minWidth = 220;
    return (screenWidth / minWidth).floor();
  }

  void buildFloatingActionButton() {
    // Implement floating action button
    if (scrollController.hasClients &&
        scrollController.position.pixels > 10.0 &&
        floatingActionButton == null) {
      setState(() {
        floatingActionButton = FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            scrollController.animateTo(0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut);
          },
          child: const Icon(Icons.arrow_upward, color: Colors.white),
        );
        isSearchClicked = false;
      });
    } else if (scrollController.position.pixels <= 10.0 &&
        floatingActionButton != null) {
      setState(() {
        floatingActionButton = null;
        isSearchClicked = true;
      });
    }
  }
}
