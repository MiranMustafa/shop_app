import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shop_app/exceptions/http_exception.dart';

import 'auth_provider.dart';
import 'product_provider.dart';

class ProductsProvider with ChangeNotifier {
  static const BASE_URL = 'https://shop-app-miran.firebaseio.com';
  List<ProductProvider> _items = [];

//  var _showFavoritesOnly = false;

  String _authToken;
  String _userId;

  void setItems(List<ProductProvider> items) {
    _items = items;
  }

  void setAuthToken(String authToken) {
    _authToken = authToken;
  }

  void setUserId(String userId) {
    _userId = userId;
  }

  String get authToken {
    return _authToken;
  }

  List<ProductProvider> get items {
    return [..._items];
  }

  List<ProductProvider> get favItems {
    return items.where((prod) => prod.isFavorite == true).toList();
  }

  ProductProvider findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(ProductProvider product) async {
    const endpoint = '/products.json';
    final fullUrl = BASE_URL + endpoint + '?auth=$_authToken';
    try {
      final response = await http.post(
        fullUrl,
        body: jsonEncode(
          product.toMap(_userId),
        ),
      );
      final newProduct = ProductProvider(
        id: jsonDecode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    const endpoint = '/products.json';
    final filterByUserEndpoint = filterByUser ? '&orderBy="userId"&equalTo="$_userId"' : '';
    final fullUrl = '$BASE_URL$endpoint?auth=$_authToken$filterByUserEndpoint';
    try {
      final response = await http.get(fullUrl);
      print(jsonDecode(response.body));
      final List<ProductProvider> loadedProducts = [];
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final favoritesEndpoint = '/userFavorites/$_userId.json';
      final favoritesUrl = BASE_URL +
          favoritesEndpoint +
          '?auth=$authToken';
      final favoritesResponse = await http.get(favoritesUrl);
      final favoritesData = jsonDecode(favoritesResponse.body);
      extractedData.forEach((prodID, prodData) {
        loadedProducts.add(ProductProvider(
          id: prodID,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'] as double,
          imageUrl: prodData['imageUrl'],
          isFavorite:
              favoritesData == null ? false : favoritesData[prodID] ?? false,
        ));
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> updateProduct(ProductProvider product) async {
    final endpoint = '/products/${product.id}.json';
    final fullUrl = BASE_URL + endpoint + '?auth=$_authToken';

    try {
      await http.patch(
        fullUrl,
        body: jsonEncode(product.toMap(_userId)),
      );
    } catch (error) {
      throw error;
    } finally {
      int i = _items.indexWhere((prod) => prod.id == product.id);
      _items[i] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final endpoint = '/products/$id.json';
    final fullUrl = BASE_URL + endpoint + '?auth=$_authToken';

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(fullUrl);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
