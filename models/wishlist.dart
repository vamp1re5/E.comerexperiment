import 'package:flutter/material.dart';

class Wishlist {
  final String id;
  final String userId;
  final List<String> productIds;
  final DateTime createdAt;

  Wishlist({
    required this.id,
    required this.userId,
    required this.productIds,
    required this.createdAt,
  });
}

class WishlistProvider extends ChangeNotifier {
  final Map<String, Wishlist> _wishlists = {};

  Wishlist? getWishlist(String userId) {
    return _wishlists[userId];
  }

  List<String> getProductIds(String userId) {
    return _wishlists[userId]?.productIds ?? [];
  }

  bool isInWishlist(String userId, String productId) {
    return _wishlists[userId]?.productIds.contains(productId) ?? false;
  }

  void addToWishlist(String userId, String productId) {
    if (_wishlists[userId] == null) {
      _wishlists[userId] = Wishlist(
        id: 'wl_$userId',
        userId: userId,
        productIds: [productId],
        createdAt: DateTime.now(),
      );
    } else {
      if (!_wishlists[userId]!.productIds.contains(productId)) {
        _wishlists[userId]!.productIds.add(productId);
      }
    }
    notifyListeners();
  }

  void removeFromWishlist(String userId, String productId) {
    _wishlists[userId]?.productIds.remove(productId);
    notifyListeners();
  }

  void clearWishlist(String userId) {
    _wishlists[userId]?.productIds.clear();
    notifyListeners();
  }
}
