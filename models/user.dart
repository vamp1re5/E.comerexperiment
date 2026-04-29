import 'package:flutter/material.dart';

import '../services/firebase_service.dart';

enum UserRole {
  buyer,
  seller,
  admin,
  superAdmin,
}

class User {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? profileImage;
  final String? address;
  final String? city;
  final String? zipCode;
  final String? country;
  final UserRole role;
  final String? storeName;
  final String? storeDescription;
  final bool? isVerified;
  final String? accountNumber;
  final String? bankName;
  final String? bankCountry;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.profileImage,
    this.address,
    this.city,
    this.zipCode,
    this.country,
    this.role = UserRole.buyer,
    this.storeName,
    this.storeDescription,
    this.isVerified = false,
    this.accountNumber,
    this.bankName,
    this.bankCountry,
  });

  factory User.fromMap(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      phone: data['phone'] as String?,
      profileImage: data['profileImage'] as String?,
      address: data['address'] as String?,
      city: data['city'] as String?,
      zipCode: data['zipCode'] as String?,
      country: data['country'] as String?,
      role: _roleFromString(data['role'] as String? ?? 'buyer'),
      storeName: data['storeName'] as String?,
      storeDescription: data['storeDescription'] as String?,
      isVerified: data['isVerified'] as bool?,
      accountNumber: data['accountNumber'] as String?,
      bankName: data['bankName'] as String?,
      bankCountry: data['bankCountry'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'profileImage': profileImage,
      'address': address,
      'city': city,
      'zipCode': zipCode,
      'country': country,
      'role': role.name,
      'storeName': storeName,
      'storeDescription': storeDescription,
      'isVerified': isVerified,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'bankCountry': bankCountry,
    };
  }

  static UserRole _roleFromString(String role) {
    switch (role) {
      case 'seller':
        return UserRole.seller;
      case 'admin':
        return UserRole.admin;
      case 'superAdmin':
        return UserRole.superAdmin;
      default:
        return UserRole.buyer;
    }
  }
}

class Order {
  final String id;
  final DateTime orderDate;
  final double totalAmount;
  final List<OrderItem> items;
  final String status;
  final String shippingAddress;
  final String? receiptUrl;
  final String paymentMethod;
  final String paymentStatus;

  Order({
    required this.id,
    required this.orderDate,
    required this.totalAmount,
    required this.items,
    required this.status,
    required this.shippingAddress,
    this.receiptUrl,
    this.paymentMethod = 'Manual Transfer',
    this.paymentStatus = 'Pending Verification',
  });

  factory Order.fromMap(Map<String, dynamic> data) {
    return Order(
      id: data['id'] as String? ?? '',
      orderDate: DateTime.parse(data['orderDate'] as String? ?? DateTime.now().toIso8601String()),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      status: data['status'] as String? ?? 'Processing',
      shippingAddress: data['shippingAddress'] as String? ?? '',
      receiptUrl: data['receiptUrl'] as String?,
      paymentMethod: data['paymentMethod'] as String? ?? 'Manual Transfer',
      paymentStatus: data['paymentStatus'] as String? ?? 'Pending Verification',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderDate': orderDate.toIso8601String(),
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toMap()).toList(),
      'status': status,
      'shippingAddress': shippingAddress,
      'receiptUrl': receiptUrl,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      quantity: data['quantity'] as int? ?? 0,
      price: (data['price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  final List<Order> _orders = [
    Order(
      id: 'ORD-001',
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      totalAmount: 99.99,
      items: [
        OrderItem(
          productId: '1',
          productName: 'Wireless Headphones',
          quantity: 1,
          price: 79.99,
        ),
      ],
      status: 'Delivered',
      shippingAddress: '123 Main St, City, Country',
      receiptUrl: null,
    ),
    Order(
      id: 'ORD-002',
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      totalAmount: 49.98,
      items: [
        OrderItem(
          productId: '4',
          productName: 'USB-C Cable',
          quantity: 2,
          price: 9.99,
        ),
      ],
      status: 'Processing',
      shippingAddress: '123 Main St, City, Country',
      receiptUrl: null,
    ),
  ];

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isBuyer => _currentUser?.role == UserRole.buyer;
  bool get isSeller => _currentUser?.role == UserRole.seller;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isSuperAdmin => _currentUser?.role == UserRole.superAdmin;
  List<Order> get orders => _orders;

  Future<void> login(String email, String password, UserRole role) async {
    final user = await FirebaseService.instance.login(email, password, role);
    _currentUser = user;
    notifyListeners();
  }

  Future<void> signup(
    String email,
    String password,
    String fullName,
    UserRole role, {
    String? storeName,
    String? storeDescription,
    String? accountNumber,
    String? bankName,
    String? bankCountry,
  }) async {
    final user = await FirebaseService.instance.signup(
      email,
      password,
      fullName,
      role,
      storeName: storeName,
      storeDescription: storeDescription,
      accountNumber: accountNumber,
      bankName: bankName,
      bankCountry: bankCountry,
    );
    _currentUser = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseService.instance.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(User updatedUser) async {
    await FirebaseService.instance.updateProfile(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }
}
