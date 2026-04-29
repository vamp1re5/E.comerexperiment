import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/return.dart';

class ReturnsPage extends StatelessWidget {
  const ReturnsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Returns'),
        elevation: 0,
      ),
      body: Consumer<ReturnProvider>(
        builder: (context, returnProvider, _) {
          final returns = returnProvider.allReturns;

          if (returns.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_return,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No returns',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: returns.length,
            itemBuilder: (context, index) {
              final ret = returns[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Return #${ret.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Order: ${ret.orderId}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(ret.status)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusLabel(ret.status),
                              style: TextStyle(
                                color: _getStatusColor(ret.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Reason: '),
                          Text(
                            ret.reason,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (ret.description != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(ret.description!),
                            const SizedBox(height: 8),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Refund Amount:',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '\$${ret.refundAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Requested: ${ret.requestDate.day}/${ret.requestDate.month}/${ret.requestDate.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(ReturnStatus status) {
    switch (status) {
      case ReturnStatus.requested:
        return Colors.blue;
      case ReturnStatus.approved:
        return Colors.green;
      case ReturnStatus.rejected:
        return Colors.red;
      case ReturnStatus.inTransit:
        return Colors.orange;
      case ReturnStatus.received:
        return Colors.purple;
      case ReturnStatus.refunded:
        return Colors.teal;
    }
  }

  String _getStatusLabel(ReturnStatus status) {
    switch (status) {
      case ReturnStatus.requested:
        return 'Requested';
      case ReturnStatus.approved:
        return 'Approved';
      case ReturnStatus.rejected:
        return 'Rejected';
      case ReturnStatus.inTransit:
        return 'In Transit';
      case ReturnStatus.received:
        return 'Received';
      case ReturnStatus.refunded:
        return 'Refunded';
    }
  }
}
