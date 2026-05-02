import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';

class SellerProductManagementPage extends StatefulWidget {
  const SellerProductManagementPage({super.key});

  @override
  State<SellerProductManagementPage> createState() => _SellerProductManagementPageState();
}

class _SellerProductManagementPageState extends State<SellerProductManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();
  final _discountPriceController = TextEditingController();

  bool _isFeatured = false;
  bool _isOnSale = false;
  bool _isLoading = false;
  Product? _editingProduct;
  List<String> _imageUrls = [];
  List<Uint8List> _imageBytes = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _discountPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final productProvider = context.watch<ProductProvider>();
    final sellerId = userProvider.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddProductDialog,
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final sellerProducts = provider.getProductsBySeller(sellerId);

          if (sellerProducts.isEmpty) {
            return const Center(
              child: Text('No products yet. Add your first product!'),
            );
          }

          return ListView.builder(
            itemCount: sellerProducts.length,
            itemBuilder: (context, index) {
              final product = sellerProducts[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: product.images.isNotEmpty
                      ? Image.network(product.images.first, width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.inventory),
                  title: Text(product.title),
                  subtitle: Text('\$${product.effectivePrice.toStringAsFixed(2)} - Stock: ${product.stock}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => _handleProductAction(value, product),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
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

  void _showAddProductDialog() {
    _showProductDialog();
  }

  void _showProductDialog({Product? product}) {
    if (product == null) {
      _editingProduct = null;
      _clearForm();
    } else {
      _editingProduct = product;
      _titleController.text = product.title;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toStringAsFixed(2);
      _stockController.text = product.stock.toString();
      _categoryController.text = product.category;
      _discountPriceController.text = product.discountPrice?.toStringAsFixed(2) ?? '';
      _isFeatured = product.isFeatured;
      _isOnSale = product.isOnSale;
      _imageUrls = List<String>.from(product.images);
      _imageBytes = [];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                if (_isOnSale)
                  TextFormField(
                    controller: _discountPriceController,
                    decoration: const InputDecoration(labelText: 'Discount Price'),
                    keyboardType: TextInputType.number,
                  ),
                SwitchListTile(
                  title: const Text('Featured'),
                  value: _isFeatured,
                  onChanged: (value) => setState(() => _isFeatured = value),
                ),
                SwitchListTile(
                  title: const Text('On Sale'),
                  value: _isOnSale,
                  onChanged: (value) => setState(() => _isOnSale = value),
                ),
                ElevatedButton(
                  onPressed: _pickImages,
                  child: const Text('Upload Images'),
                ),
                if (_imageUrls.isNotEmpty)
                  Text('${_imageUrls.length} images selected'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _isLoading ? null : _saveProduct,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _stockController.clear();
    _categoryController.clear();
    _discountPriceController.clear();
    _isFeatured = false;
    _isOnSale = false;
    _imageUrls.clear();
    _imageBytes.clear();
  }

  Future<void> _pickImages() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload is not supported on web. Please use the mobile app to add product images.')),
      );
      return;
    }

    // File picker removed for web compatibility
    // TODO: Implement web-compatible image picker when needed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image upload is currently only available on mobile devices.')),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      final productProvider = context.read<ProductProvider>();
      final sellerId = userProvider.currentUser!.id;

      final uploadedUrls = <String>[];
      for (int i = 0; i < _imageBytes.length; i++) {
        final url = await FirebaseService.instance.uploadReceipt(
          _imageBytes[i],
          'product_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          contentType: 'image/jpeg',
        );
        uploadedUrls.add(url);
      }

      final product = Product(
        id: _editingProduct?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        rating: _editingProduct?.rating ?? 0,
        reviews: _editingProduct?.reviews ?? 0,
        category: _categoryController.text,
        images: _imageUrls.isNotEmpty ? _imageUrls : (_editingProduct?.images ?? []),
        stock: int.parse(_stockController.text),
        seller: sellerId,
        isFeatured: _isFeatured,
        isOnSale: _isOnSale,
        discountPrice: _isOnSale ? double.tryParse(_discountPriceController.text) : null,
        createdAt: _editingProduct?.createdAt ?? DateTime.now(),
      );

      if (_editingProduct != null) {
        await productProvider.updateProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );
      } else {
        await productProvider.addProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
      }
      _editingProduct = null;
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleProductAction(String action, Product product) {
    switch (action) {
      case 'edit':
        _showProductDialog(product: product);
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Product'),
            content: const Text('Are you sure you want to delete this product?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  await context.read<ProductProvider>().deleteProduct(product.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product deleted')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
    }
  }
}