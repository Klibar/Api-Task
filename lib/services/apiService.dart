import 'dart:convert';
import 'package:http/http.dart' as http;

class Apiservice {
  static Future<List<dynamic>> getData({String? category}) async {
    String url =
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=c587dd8ba4e1404d8de3de50318d0b38';

    if (category != null && category.toLowerCase() != 'all') {
      url += '&category=${category.toLowerCase()}';
    }

    final data = await http.get(Uri.parse(url));
    final dataUnlocked = jsonDecode(data.body);
    List<dynamic> newsData = dataUnlocked['articles'] ?? [];
    return newsData;
  }
}
