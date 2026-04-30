import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';

class OrderConfirmationPage extends StatefulWidget {
  final String orderId;

  const OrderConfirmationPage({super.key, required this.orderId});

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  bool _isLoading = true;
  Order? _order;
  final Map<String, User> _sellers = {};

  @override
  void initState() {
    super.initState();
    _loadSellerInfo();
  }

  Future<void> _loadSellerInfo() async {
    final userProvider = context.read<UserProvider>();
    final productProvider = context.read<ProductProvider>();

    Order? order;
    for (final candidate in userProvider.orders) {
      if (candidate.id == widget.orderId) {
        order = candidate;
        break;
      }
    }

    if (order == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final sellerIds = <String>{};
    for (final item in order.items) {
      final product = productProvider.getProductById(item.productId);
      if (product != null && product.seller.isNotEmpty) {
        sellerIds.add(product.seller);
      }
    }

    for (final sellerId in sellerIds) {
      final doc = await FirebaseService.instance.firestore.collection('users').doc(sellerId).get();
      if (doc.exists) {
        _sellers[sellerId] = User.fromMap(doc.data()!, doc.id);
      }
    }

    setState(() {
      _order = order;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sellers = _sellers.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      const Text(
                        'Order not found.',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Return Home'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: 60,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Order Confirmed!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Order ID: ${_order!.id}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your order has been successfully placed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Order Summary',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              ..._order!.items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(item.productName)),
                                      Text('x${item.quantity}'),
                                      const SizedBox(width: 12),
                                      Text('\$${item.price.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('\$${_order!.totalAmount.toStringAsFixed(2)}'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Shipping Address: ${_order!.shippingAddress}'),
                              const SizedBox(height: 4),
                              Text('Payment Status: ${_order!.paymentStatus}'),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Seller Account Details',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              if (sellers.isEmpty)
                                const Text('Seller details are not available at this time.')
                              else
                                ...sellers.map((seller) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(seller.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text('Email: ${seller.email}'),
                                        if (seller.bankName != null) Text('Bank: ${seller.bankName}'),
                                        if (seller.accountNumber != null) Text('Account: ${seller.accountNumber}'),
                                        if (seller.bankCountry != null) Text('Country: ${seller.bankCountry}'),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ),
                      FilledButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Continue Shopping'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => context.push('/orders'),
                        child: const Text('View Orders'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
