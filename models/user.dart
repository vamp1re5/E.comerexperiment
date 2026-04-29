import 'package:flutter/material.dart';

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
  final String? storeName; // For sellers
  final String? storeDescription; // For sellers
  final bool? isVerified; // For sellers

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
  });
}

class Order {
  final String id;
  final DateTime orderDate;
  final double totalAmount;
  final List<OrderItem> items;
  final String status;
  final String shippingAddress;

  Order({
    required this.id,
    required this.orderDate,
    required this.totalAmount,
    required this.items,
    required this.status,
    required this.shippingAddress,
  });
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
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock different users based on role
    if (role == UserRole.seller) {
      _currentUser = User(
        id: '125',
        email: email,
        fullName: 'Seller Pro',
        phone: '+1234567890',
        address: '456 Business Ave',
        city: 'Los Angeles',
        zipCode: '90001',
        country: 'USA',
        role: UserRole.seller,
        storeName: 'Tech Store',
        storeDescription: 'Premium electronics and gadgets',
        isVerified: true,
      );
    } else if (role == UserRole.admin) {
      _currentUser = User(
        id: '126',
        email: email,
        fullName: 'Admin User',
        phone: '+1234567890',
        role: UserRole.admin,
      );
    } else if (role == UserRole.superAdmin) {
      _currentUser = User(
        id: '127',
        email: email,
        fullName: 'SuperAdmin',
        phone: '+1234567890',
        role: UserRole.superAdmin,
      );
    } else {
      _currentUser = User(
        id: '123',
        email: email,
        fullName: 'John Doe',
        phone: '+1234567890',
        address: '123 Main Street',
        city: 'New York',
        zipCode: '10001',
        country: 'USA',
        role: UserRole.buyer,
      );
    }
    notifyListeners();
  }

  Future<void> signup(
    String email,
    String password,
    String fullName,
    UserRole role, {
    String? storeName,
    String? storeDescription,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(
      id: '124',
      email: email,
      fullName: fullName,
      role: role,
      storeName: storeName,
      storeDescription: storeDescription,
      isVerified: role == UserRole.seller ? false : null,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(User updatedUser) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = updatedUser;
    notifyListeners();
  }

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }
}
