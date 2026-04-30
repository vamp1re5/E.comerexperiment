import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';
import '../models/product.dart';

class SellerOrderManagementPage extends StatefulWidget {
  const SellerOrderManagementPage({super.key});

  @override
  State<SellerOrderManagementPage> createState() => _SellerOrderManagementPageState();
}

class _SellerOrderManagementPageState extends State<SellerOrderManagementPage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final sellerId = userProvider.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('items', arrayContainsAny: [
              {'seller': sellerId}
            ])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;
              final orderId = orders[index].id;
              final items = orderData['items'] as List<dynamic>? ?? [];
              final sellerItems = items.where((item) => item['seller'] == sellerId).toList();

              if (sellerItems.isEmpty) return const SizedBox();

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text('Order #$orderId'),
                  subtitle: Text('Status: ${orderData['status'] ?? 'Unknown'}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...sellerItems.map((item) => ListTile(
                            title: Text(item['productName'] ?? ''),
                            subtitle: Text('Quantity: ${item['quantity']} - Price: \$${item['price']}'),
                          )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Payment Status:'),
                              Text(orderData['paymentStatus'] ?? 'Unknown'),
                            ],
                          ),
                          if (orderData['receiptUrl'] != null)
                            TextButton(
                              onPressed: () {
                                // TODO: Open receipt
                              },
                              child: const Text('View Receipt'),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _updateOrderStatus(orderId, 'Shipped'),
                                  child: const Text('Mark as Shipped'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _updateOrderStatus(orderId, 'Delivered'),
                                  child: const Text('Mark as Delivered'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': status,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked as $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}