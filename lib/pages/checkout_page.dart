import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/cart.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _currentStep = 0;
  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>()];

  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _zipController;
  late TextEditingController _countryController;
  late TextEditingController _cardController;
  late TextEditingController _expiryController;
  late TextEditingController _cvvController;
  Uint8List? _receiptBytes;
  String? _receiptFileName;
  bool _isUploadingReceipt = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().currentUser;
    _addressController = TextEditingController(text: user?.address ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _zipController = TextEditingController(text: user?.zipCode ?? '');
    _countryController = TextEditingController(text: user?.country ?? '');
    _cardController = TextEditingController();
    _expiryController = TextEditingController();
    _cvvController = TextEditingController();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Stepper(
                  currentStep: _currentStep,
                  onStepContinue: _onStepContinue,
                  onStepCancel: _onStepCancel,
                  steps: [
                    Step(
                      title: const Text('Shipping Address'),
                      state: _currentStep > 0
                          ? StepState.complete
                          : StepState.editing,
                      isActive: _currentStep >= 0,
                      content: Form(
                        key: _formKeys[0],
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Street Address',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Address is required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _cityController,
                                    decoration: const InputDecoration(
                                      labelText: 'City',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) =>
                                        value?.isEmpty ?? true
                                            ? 'City is required'
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _zipController,
                                    decoration: const InputDecoration(
                                      labelText: 'ZIP Code',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) =>
                                        value?.isEmpty ?? true
                                            ? 'ZIP is required'
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _countryController,
                              decoration: const InputDecoration(
                                labelText: 'Country',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Country is required'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Step(
                      title: const Text('Payment Method'),
                      state: _currentStep > 1
                          ? StepState.complete
                          : StepState.editing,
                      isActive: _currentStep >= 1,
                      content: Form(
                        key: _formKeys[1],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Manual Payment Transfer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Please transfer the total amount to the seller account and upload a receipt for verification.',
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.upload_file),
                              label: Text(
                                _receiptFileName == null
                                    ? 'Upload Receipt'
                                    : 'Receipt: $_receiptFileName',
                              ),
                              onPressed: _isUploadingReceipt ? null : _selectReceipt,
                            ),
                            if (_receiptFileName != null) ...[
                              const SizedBox(height: 12),
                              Text('Receipt selected: $_receiptFileName'),
                            ],
                            const SizedBox(height: 16),
                            Text(
                              'Seller transfer details are shared in the order confirmation screen after checkout.',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Step(
                      title: const Text('Order Summary'),
                      state: StepState.editing,
                      isActive: _currentStep >= 2,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...cart.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item.product.title} x${item.quantity}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        FutureBuilder<User?>(
                                          future: _getSellerInfo(item.product.seller),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData && snapshot.data != null) {
                                              final seller = snapshot.data!;
                                              return Text(
                                                'Seller: ${seller.storeName ?? seller.fullName}',
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              );
                                            }
                                            return const SizedBox();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${item.totalPrice.toStringAsFixed(2)}',
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:'),
                              Text('\$${cart.totalPrice.toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tax (10%):'),
                              Text(
                                '\$${(cart.totalPrice * 0.1).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Shipping:'),
                              Text(cart.totalPrice > 100 ? 'FREE' : '\$5.00'),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${(cart.totalPrice + (cart.totalPrice * 0.1) + (cart.totalPrice > 100 ? 0 : 5)).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_formKeys[0].currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_receiptBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload your receipt to continue.')),
        );
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 2) {
      _completeOrder();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _completeOrder() async {
    final cart = context.read<CartProvider>();
    final userProvider = context.read<UserProvider>();

    final receiptUrl = _receiptBytes != null
        ? await FirebaseService.instance.uploadReceipt(
            _receiptBytes!,
            'receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
            contentType: 'application/pdf',
          )
        : null;

    final order = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      orderDate: DateTime.now(),
      totalAmount: cart.totalPrice + (cart.totalPrice * 0.1) + 5,
      items: cart.items
          .map((item) => OrderItem(
                productId: item.product.id,
                productName: item.product.title,
                quantity: item.quantity,
                price: item.product.effectivePrice,
              ))
          .toList(),
      status: 'Processing',
      shippingAddress: _addressController.text,
      receiptUrl: receiptUrl,
      paymentStatus: 'Pending Verification',
    );

    userProvider.addOrder(order);
    cart.clearCart();

    if (mounted) {
      context.go('/order-confirmation/${order.id}');
    }
  }

  Future<User?> _getSellerInfo(String sellerId) async {
    final doc = await FirebaseService.instance.firestore.collection('users').doc(sellerId).get();
    if (!doc.exists) return null;
    return User.fromMap(doc.data()!, doc.id);
  }
