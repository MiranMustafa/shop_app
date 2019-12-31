import 'package:flutter/foundation.dart';

class CartModel {
  final String id;
  final String productID;
  final String title;
  final int quantity;
  final double price;

  CartModel({
    @required this.id,
    @required this.productID,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });

  Map<String,dynamic> toMap() {
    return {
      'id' : id,
      'productID' : productID,
      'title' : title,
      'quantity' : quantity,
      'price' : price,
    };
  }
}

class CartProvider with ChangeNotifier {
  Map<String, CartModel> _items = {};

  Map<String, CartModel> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(
    String productId,
    double price,
    String title,
  ) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartModel(
            id: existingCartItem.id,
            productID: existingCartItem.productID,
            title: existingCartItem.title,
            quantity: existingCartItem.quantity + 1,
            price: existingCartItem.price),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartModel(
            id: DateTime.now().toString(),
            productID: productId,
            title: title,
            quantity: 1,
            price: price),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId].quantity > 1) {
      _items.update(
        productId,
        (existingItem) => CartModel(
            id: existingItem.id,
            productID: existingItem.productID,
            title: existingItem.title,
            quantity: existingItem.quantity - 1,
            price: existingItem.price),
      );
      notifyListeners();
      return ;
    }
    else {
      _items.remove(productId);
      notifyListeners();
    }
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
