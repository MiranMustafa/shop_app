import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/widgets/order_item.dart';

import './cart_provider.dart';

class OrderModel {
  final String id;
  final double amount;
  final List<CartModel> products;
  final DateTime dateTime;

  OrderModel({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'datetime': dateTime,
      'products': {
        products.forEach(
          (cartModel) {
            return cartModel.toMap();
          },
        ),
      }
    };
  }
}

class OrderProvider with ChangeNotifier {
  static const BASE_URL = 'https://shop-app-miran.firebaseio.com';
  List<OrderModel> _orders = [];
  String _authToken;
  String _userId;

  List<OrderModel> get orders {
    return [..._orders];
  }

  void setAuthToken(String authToken) {
    _authToken = authToken;
  }

  void setUserId(String userId) {
    _userId = userId;
  }

  Future<void> addOrder(List<CartModel> cartProducts, double total) async {
    final endpoint = '/orders/$_userId.json';
    final fullUrl = BASE_URL + endpoint + '?auth=$_authToken';
    final dateTime = DateTime.now();
    try {
      final response = await http.post(fullUrl,
          body: jsonEncode({
            'amount': total,
            'products': cartProducts.map((cartModel) {
              return cartModel.toMap();
            }).toList(),
            'datetime': dateTime.toIso8601String(),
          }));
      final newOrder = OrderModel(
        id: jsonDecode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: dateTime,
      );
      _orders.insert(0, newOrder);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetOrders() async {
    final endpoint = '/orders/$_userId.json';
    final fullUrl = BASE_URL + endpoint + '?auth=$_authToken';
    try {
      final response = await http.get(fullUrl);
      final List<OrderModel> loadedOrders = [];
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderModel(
            id: orderId,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['datetime']),
            products: (orderData['products'] as List<dynamic>)
                .map((item) => CartModel(
                      title: item['title'],
                      price: item['price'],
                      quantity: item['quantity'],
                      id: item['id'],
                      productID: item['productID'],
                    ))
                .toList(),
          ),
        );
      });
      print(loadedOrders.length);
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }
}
