import 'dart:convert';
import 'package:http/http.dart' as http;

class PixabayResponse {
  static const String _baseUrl = 'https://pixabay.com/api/';
  int total;
  int totalHits;
  List<Hit> hits;

  PixabayResponse({required this.total, required this.totalHits, required this.hits});

  factory PixabayResponse.fromJson(Map<String, dynamic> json) {
    return PixabayResponse(
      total: json['total'],
      totalHits: json['totalHits'],
      hits: (json['hits'] as List).map((hit) => Hit.fromJson(hit)).toList(),
    );
  }

//   Parameters
// key (required)	str	Your API key: 43665324-9871f060f8496ca0841b7e412
// q	str	A URL encoded search term. If omitted, all images are returned. This value may not exceed 100 characters.
// Example: "yellow+flower"
// lang	str	Language code of the language to be searched in.
// Accepted values: cs, da, de, en, es, fr, id, it, hu, nl, no, pl, pt, ro, sk, fi, sv, tr, vi, th, bg, ru, el, ja, ko, zh
// Default: "en"
// id	str	Retrieve individual images by ID.
// image_type	str	Filter results by image type.
// Accepted values: "all", "photo", "illustration", "vector"
// Default: "all"
// orientation	str	Whether an image is wider than it is tall, or taller than it is wide.
// Accepted values: "all", "horizontal", "vertical"
// Default: "all"
// category	str	Filter results by category.
// Accepted values: backgrounds, fashion, nature, science, education, feelings, health, people, religion, places, animals, industry, computer, food, sports, transportation, travel, buildings, business, music
// min_width	int	Minimum image width.
// Default: "0"
// min_height	int	Minimum image height.
// Default: "0"
// colors	str	Filter images by color properties. A comma separated list of values may be used to select multiple properties.
// Accepted values: "grayscale", "transparent", "red", "orange", "yellow", "green", "turquoise", "blue", "lilac", "pink", "white", "gray", "black", "brown"
// editors_choice	bool	Select images that have received an Editor's Choice award.
// Accepted values: "true", "false"
// Default: "false"
// safesearch	bool	A flag indicating that only images suitable for all ages should be returned.
// Accepted values: "true", "false"
// Default: "false"
// order	str	How the results should be ordered.
// Accepted values: "popular", "latest"
// Default: "popular"
// page	int	Returned search results are paginated. Use this parameter to select the page number.
// Default: 1
// per_page	int	Determine the number of results per page.
// Accepted values: 3 - 200
// Default: 20
// callback	string	JSONP callback function name
// pretty	bool	Indent JSON output. This option should not be used in production.
// Accepted values: "true", "false"
// Default: "false"

  static Future<PixabayResponse> searchImages(String query, {int page = 1, int perPage = 20}) async {
    final response = await http.get(Uri.parse('$_baseUrl?key=43665324-9871f060f8496ca0841b7e412&q=$query&page=$page&per_page=$perPage'));
    if (response.statusCode == 200) {
      return PixabayResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load images');
    }
  }
}

class Hit {
  int? id;
  String? pageURL;
  String? type;
  String? tags;
  String? previewURL;
  int? previewWidth;
  int? previewHeight;
  String? webformatURL;
  int? webformatWidth;
  int? webformatHeight;
  String? largeImageURL;
  String? fullHDURL;
  String? imageURL;
  int? imageWidth;
  int? imageHeight;
  int? imageSize;
  int? views;
  int? downloads;
  int? likes;
  int? comments;
  int? userId;
  String? user;
  String? userImageURL;
  
  Hit({
    this.id,
    this.pageURL,
    this.type,
    this.tags,
    this.previewURL,
    this.previewWidth,
    this.previewHeight,
    this.webformatURL,
    this.webformatWidth,
    this.webformatHeight,
    this.largeImageURL,
    this.fullHDURL,
    this.imageURL,
    this.imageWidth,
    this.imageHeight,
    this.imageSize,
    this.views,
    this.downloads,
    this.likes,
    this.comments,
    this.userId,
    this.user,
    this.userImageURL,
  });

  factory Hit.fromJson(Map<String, dynamic> json) {
    return Hit(
      id: json['id'],
      pageURL: json['pageURL'],
      type: json['type'],
      tags: json['tags'],
      previewURL: json['previewURL'],
      previewWidth: json['previewWidth'],
      previewHeight: json['previewHeight'],
      webformatURL: json['webformatURL'],
      webformatWidth: json['webformatWidth'],
      webformatHeight: json['webformatHeight'],
      largeImageURL: json['largeImageURL'],
      fullHDURL: json['fullHDURL'],
      imageURL: json['imageURL'],
      imageWidth: json['imageWidth'],
      imageHeight: json['imageHeight'],
      imageSize: json['imageSize'],
      views: json['views'],
      downloads: json['downloads'],
      likes: json['likes'],
      comments: json['comments'],
      userId: json['user_id'],
      user: json['user'],
      userImageURL: json['userImageURL'],
    );
  }
}
