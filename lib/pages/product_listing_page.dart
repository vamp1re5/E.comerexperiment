import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class ProductListingPage extends StatefulWidget {
  const ProductListingPage({super.key});

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  late String _selectedCategory;
  bool _showSaleOnly = false;
  String _sortBy = 'popularity'; // popularity, price_low, price_high, rating

  @override
  void initState() {
    super.initState();
    _selectedCategory = 'All';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          List<Product> products = productProvider.products;

          // Filter by category
          if (_selectedCategory != 'All') {
            products = products
                .where((p) => p.category == _selectedCategory)
                .toList();
          }

          // Filter by sale
          if (_showSaleOnly) {
            products = products.where((p) => p.isOnSale).toList();
          }

          // Sort products
          switch (_sortBy) {
            case 'price_low':
              products.sort((a, b) =>
                  a.effectivePrice.compareTo(b.effectivePrice));
              break;
            case 'price_high':
              products.sort((a, b) =>
                  b.effectivePrice.compareTo(a.effectivePrice));
              break;
            case 'rating':
              products.sort((a, b) => b.rating.compareTo(a.rating));
              break;
            default:
              break;
          }

          return Column(
            children: [
              // Filter chips
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategory == 'All',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = 'All');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ...productProvider.categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategory = category);
                              }
                            },
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Sale Only'),
                        selected: _showSaleOnly,
                        onSelected: (selected) {
                          setState(() => _showSaleOnly = selected);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Products grid
              Expanded(
                child: products.isEmpty
                    ? const Center(
                        child: Text('No products found'),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: products[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...[
              ('Popularity', 'popularity'),
              ('Price: Low to High', 'price_low'),
              ('Price: High to Low', 'price_high'),
              ('Highest Rating', 'rating'),
            ].map((option) {
              return RadioListTile<String>(
                title: Text(option.$1),
                value: option.$2,
                groupValue: _sortBy,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _sortBy = value);
                    Navigator.pop(context);
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
