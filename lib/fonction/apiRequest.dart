import 'package:http/http.dart' as http;
import 'dart:convert';

requestAPI(String query) async {
  try {
    final response = await http.get(Uri.parse('https://api.jikan.moe/v4/manga?q=$query&genres_exclude=9,12,26,28,49,65'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      print('Erreur : ${response.statusCode}');
      return null;
    }
} catch (e) {
    print('Exception lors de la recherche : $e');
    return null;
  }
}