import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/firebase_service.dart';

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
  String? currentUserId;

  bool get hasLoadedWishlist => currentUserId != null && _wishlists.containsKey(currentUserId!);

  List<String> get wishlistItems {
    if (currentUserId == null) return [];
    return getProductIds(currentUserId!);
  }

  Wishlist? getWishlist(String userId) {
    return _wishlists[userId];
  }

  List<String> getProductIds(String userId) {
    return _wishlists[userId]?.productIds ?? [];
  }

  bool isInWishlist(String productId) {
    if (currentUserId == null) return false;
    return getProductIds(currentUserId!).contains(productId);
  }

  Future<void> loadWishlist(String userId) async {
    currentUserId = userId;
    final doc = await FirebaseService.instance.firestore.collection('wishlists').doc(userId).get();
    if (doc.exists) {
      final data = doc.data();
      final ids = List<String>.from(data?['productIds'] ?? []);
      final createdAt = (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      _wishlists[userId] = Wishlist(
        id: doc.id,
        userId: userId,
        productIds: ids,
        createdAt: createdAt,
      );
    } else {
      _wishlists[userId] = Wishlist(
        id: userId,
        userId: userId,
        productIds: [],
        createdAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  Future<void> addToWishlist(String userId, String productId) async {
    final wishlist = _wishlists[userId] ?? Wishlist(
      id: userId,
      userId: userId,
      productIds: [],
      createdAt: DateTime.now(),
    );

    if (!wishlist.productIds.contains(productId)) {
      wishlist.productIds.add(productId);
      _wishlists[userId] = wishlist;
      await FirebaseService.instance.firestore.collection('wishlists').doc(userId).set(
        {
          'productIds': FieldValue.arrayUnion([productId]),
          'createdAt': wishlist.createdAt,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    final wishlist = _wishlists[userId];
    if (wishlist == null) return;

    wishlist.productIds.remove(productId);
    await FirebaseService.instance.firestore.collection('wishlists').doc(userId).set(
      {
        'productIds': FieldValue.arrayRemove([productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    notifyListeners();
  }

  Future<void> clearWishlist(String userId) async {
    _wishlists[userId]?.productIds.clear();
    await FirebaseService.instance.firestore.collection('wishlists').doc(userId).set(
      {
        'productIds': [],
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    notifyListeners();
  }

  Future<void> addWishlistItem(Product product) async {
    if (currentUserId == null) return;
    await addToWishlist(currentUserId!, product.id);
  }

  Future<void> removeWishlistItem(String productId) async {
    if (currentUserId == null) return;
    await removeFromWishlist(currentUserId!, productId);
  }
}
