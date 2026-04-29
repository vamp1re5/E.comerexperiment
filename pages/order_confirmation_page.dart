import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderConfirmationPage extends StatelessWidget {
  final String orderId;

  const OrderConfirmationPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 32),
            const Text(
              'Order Confirmed!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Order ID: $orderId',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order has been successfully placed.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const Text(
              'You will receive a confirmation email shortly.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
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
