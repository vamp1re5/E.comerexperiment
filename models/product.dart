import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firebase_service.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final double rating;
  final int reviews;
  final String category;
  final List<String> images;
  final int stock;
  final String seller;
  final bool isFeatured;
  final bool isOnSale;
  final double? discountPrice;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.category,
    required this.images,
    required this.stock,
    required this.seller,
    this.isFeatured = false,
    this.isOnSale = false,
    this.discountPrice,
    required this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      reviews: data['reviews'] as int? ?? 0,
      category: data['category'] as String? ?? '',
      images: List<String>.from(data['images'] ?? []),
      stock: data['stock'] as int? ?? 0,
      seller: data['seller'] as String? ?? '',
      isFeatured: data['isFeatured'] as bool? ?? false,
      isOnSale: data['isOnSale'] as bool? ?? false,
      discountPrice: (data['discountPrice'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      'category': category,
      'images': images,
      'stock': stock,
      'seller': seller,
      'isFeatured': isFeatured,
      'isOnSale': isOnSale,
      'discountPrice': discountPrice,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  double get effectivePrice => discountPrice ?? price;
  double get discount => isOnSale ? ((price - (discountPrice ?? price)) / price * 100) : 0;
}

class ProductProvider extends ChangeNotifier {
  final List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  List<Product> get featuredProducts => _products.where((p) => p.isFeatured).toList();
  List<Product> get onSaleProducts => _products.where((p) => p.isOnSale).toList();

  List<String> get categories => _products.map((p) => p.category).toSet().toList();

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance.collection('products').get();
      _products.clear();
      _products.addAll(snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)));
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    await FirebaseFirestore.instance.collection('products').doc(product.id).set(product.toMap());
    _products.add(product);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    await FirebaseFirestore.instance.collection('products').doc(product.id).update(product.toMap());
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    await FirebaseFirestore.instance.collection('products').doc(productId).delete();
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  List<Product> getProductsBySeller(String sellerId) {
    return _products.where((p) => p.seller == sellerId).toList();
  }

  List<Product> searchProducts(String query) {
    return _products.where((p) =>
      p.title.toLowerCase().contains(query.toLowerCase()) ||
      p.description.toLowerCase().contains(query.toLowerCase()) ||
      p.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  List<Product> filterProducts(String category, double? minPrice, double? maxPrice) {
    return _products.where((p) {
      if (category.isNotEmpty && p.category != category) return false;
      if (minPrice != null && p.effectivePrice < minPrice) return false;
      if (maxPrice != null && p.effectivePrice > maxPrice) return false;
      return true;
    }).toList();
  }
}
      isFeatured: true,
      isOnSale: true,
      discountPrice: 59.99,
    ),
    Product(
      id: '2',
      title: 'Smart Watch',
      description: 'Advanced fitness tracking and notifications',
      price: 199.99,
      rating: 4.8,
      reviews: 512,
      category: 'Electronics',
      images: ['https://via.placeholder.com/300?text=SmartWatch'],
      stock: 30,
      seller: 'TechStore',
      isFeatured: true,
    ),
    Product(
      id: '3',
      title: 'Laptop Stand',
      description: 'Adjustable aluminum laptop stand for better posture',
      price: 29.99,
      rating: 4.2,
      reviews: 156,
      category: 'Accessories',
      images: ['https://via.placeholder.com/300?text=LaptopStand'],
      stock: 100,
      seller: 'OfficeGear',
    ),
    Product(
      id: '4',
      title: 'USB-C Cable',
      description: 'Durable 2-meter USB-C charging cable',
      price: 12.99,
      rating: 4.6,
      reviews: 789,
      category: 'Cables',
      images: ['https://via.placeholder.com/300?text=USBCable'],
      stock: 200,
      seller: 'CablePro',
      isOnSale: true,
      discountPrice: 9.99,
    ),
    Product(
      id: '5',
      title: 'Phone Case',
      description: 'Protective phone case with excellent grip',
      price: 19.99,
      rating: 4.3,
      reviews: 445,
      category: 'Accessories',
      images: ['https://via.placeholder.com/300?text=PhoneCase'],
      stock: 150,
      seller: 'CaseMaster',
    ),
    Product(
      id: '6',
      title: 'Portable Charger',
      description: '20000mAh portable power bank with fast charging',
      price: 35.99,
      rating: 4.7,
      reviews: 623,
      category: 'Electronics',
      images: ['https://via.placeholder.com/300?text=PowerBank'],
      stock: 75,
      seller: 'PowerTech',
      isFeatured: true,
    ),
  ];

  List<Product> get products => _products;
  List<Product> get featuredProducts => _products.where((p) => p.isFeatured).toList();
  List<Product> get saleProducts => _products.where((p) => p.isOnSale).toList();

  List<String> get categories {
    return _products.map((p) => p.category).toSet().toList();
  }

  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> searchProducts(String query) {
    return _products
        .where((p) =>
            p.title.toLowerCase().contains(query.toLowerCase()) ||
            p.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
