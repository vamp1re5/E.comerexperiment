import 'package:flutter/material.dart';
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.effectivePrice * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addToCart(Product product, {int quantity = 1}) {
    try {
      final existingIndex =
          _items.indexWhere((item) => item.product.id == product.id);

      if (existingIndex >= 0) {
        _items[existingIndex].quantity += quantity;
      } else {
        _items.add(CartItem(product: product, quantity: quantity));
      }
      notifyListeners();
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    try {
      final item = _items.firstWhere((item) => item.product.id == productId);
      if (quantity > 0) {
        item.quantity = quantity;
      } else {
        removeFromCart(productId);
      }
      notifyListeners();
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  int getQuantityInCart(String productId) {
    try {
      return _items.firstWhere((item) => item.product.id == productId).quantity;
    } catch (e) {
      return 0;
    }
  }
}
