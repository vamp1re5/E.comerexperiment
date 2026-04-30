import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerPayoutDashboardPage extends StatefulWidget {
  const SellerPayoutDashboardPage({super.key});

  @override
  State<SellerPayoutDashboardPage> createState() => _SellerPayoutDashboardPageState();
}

class _SellerPayoutDashboardPageState extends State<SellerPayoutDashboardPage> {
  late Stream<QuerySnapshot> _payoutsStream;
  late Stream<QuerySnapshot> _ordersStream;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _payoutsStream = FirebaseFirestore.instance
          .collection('payouts')
          .where('sellerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots();

      _ordersStream = FirebaseFirestore.instance
          .collection('orders')
          .where('sellerId', isEqualTo: userId)
          .where('status', isEqualTo: 'delivered')
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payout Dashboard'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Summary Cards
            StreamBuilder<QuerySnapshot>(
              stream: _ordersStream,
              builder: (context, ordersSnapshot) {
                if (ordersSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                double totalEarned = 0;
                double pendingPayout = 0;
                double availableBalance = 0;

                if (ordersSnapshot.hasData) {
                  for (var doc in ordersSnapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final amount = data['totalAmount'] ?? 0.0;
                    final status = data['payoutStatus'] ?? 'pending';

                    totalEarned += amount;

                    if (status == 'pending') {
                      pendingPayout += amount;
                    } else if (status == 'completed') {
                      availableBalance += amount;
                    }
                  }
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildBalanceCard(
                            'Total Earned',
                            '\$${totalEarned.toStringAsFixed(2)}',
                            Colors.green,
                            Icons.account_balance_wallet,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBalanceCard(
                            'Pending Payout',
                            '\$${pendingPayout.toStringAsFixed(2)}',
                            Colors.orange,
                            Icons.hourglass_top,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBalanceCard(
                      'Available Balance',
                      '\$${availableBalance.toStringAsFixed(2)}',
                      Colors.blue,
                      Icons.check_circle,
                      fullWidth: true,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Request Payout Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _requestPayout(),
                icon: const Icon(Icons.payment),
                label: const Text('Request Payout'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Payout History
            const Text(
              'Payout History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            StreamBuilder<QuerySnapshot>(
              stream: _payoutsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final payouts = snapshot.data?.docs ?? [];

                if (payouts.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No payout history yet',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: payouts.length,
                  itemBuilder: (context, index) {
                    final payoutDoc = payouts[index];
                    final payoutData = payoutDoc.data() as Map<String, dynamic>;
                    final amount = payoutData['amount'] ?? 0.0;
                    final status = payoutData['status'] ?? 'pending';
                    final createdAt = (payoutData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final method = payoutData['method'] ?? 'bank_transfer';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          _getPayoutStatusIcon(status),
                          color: _getPayoutStatusColor(status),
                        ),
                        title: Text('\$${amount.toStringAsFixed(2)}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Method: ${method.replaceAll('_', ' ').toUpperCase()}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPayoutStatusColor(status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: _getPayoutStatusColor(status),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color color, IconData icon, {bool fullWidth = false}) {
    return Card(
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPayout() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to find seller account.')),
      );
      return;
    }

    final ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: userId)
        .where('status', isEqualTo: 'delivered')
        .where('payoutStatus', isEqualTo: 'pending')
        .get();

    if (ordersSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No eligible payout orders available.')),
      );
      return;
    }

    double payoutAmount = 0;
    for (var doc in ordersSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      payoutAmount += (data['totalAmount'] ?? 0.0) as double;
    }

    if (payoutAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No payout amount available for request.')),
      );
      return;
    }

    try {
      await FirebaseService.instance.requestPayout(userId, payoutAmount);
      for (var doc in ordersSnapshot.docs) {
        await FirebaseFirestore.instance.collection('orders').doc(doc.id).update({
          'payoutStatus': 'processing',
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payout request of \$${payoutAmount.toStringAsFixed(2)} submitted.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting payout: $e')),
      );
    }
  }

  IconData _getPayoutStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'processing':
        return Icons.hourglass_top;
      case 'failed':
        return Icons.error;
      default:
        return Icons.schedule;
    }
  }

  Color _getPayoutStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}