import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ProductProvider with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  static const BASE_URL = 'https://shop-app-miran.firebaseio.com';

  ProductProvider({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    @required this.price,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String authToken, userId) async {
    final endpoint = '/userFavorites/$userId/$id.json';
    final fullUrl = BASE_URL + endpoint + '?auth=$authToken';

    isFavorite = !isFavorite;
    notifyListeners();
    http
        .put(fullUrl,
            body: jsonEncode(
              isFavorite,
            ))
        .then((response) {
      print(response.statusCode);
      if (response.statusCode >= 400) {
        isFavorite = !isFavorite;
        notifyListeners();
      }
    });
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'userId' : userId,
    };
  }
}
