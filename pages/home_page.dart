import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../models/cart.dart';
import '../models/notification.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/flash_sale_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Store'),
        elevation: 0,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notifications, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (notifications.unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${notifications.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => context.push('/cart'),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBar(
                onSearch: (query) => _showSearchResults(query, context),
              ),
            ),

            // Flash Sale Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FlashSaleBanner(
                onTap: () => context.push('/products'),
              ),
            ),

            const SizedBox(height: 24),

            // Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/categories'),
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),

            // Category List
            Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                final categories = productProvider.categories;
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategoryIndex = index);
                            final category = categories[index];
                            context.push('/products?category=$category');
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.primaries[index %
                                          Colors.primaries.length]
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: _selectedCategoryIndex == index
                                      ? Border.all(
                                          color: Colors.primaries[index %
                                              Colors.primaries.length],
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    categories[index].substring(0, 1),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.primaries[index %
                                          Colors.primaries.length],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  categories[index],
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Featured Products
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/products'),
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),

            Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                final featured = productProvider.featuredProducts;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: featured.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: featured[index]);
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // Sale Products
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'On Sale Now',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/products?sale=true'),
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),

            Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                final onSale = productProvider.saleProducts;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: onSale.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: onSale[index]);
                  },
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showSearchResults(String query, BuildContext context) {
    final results =
        context.read<ProductProvider>().searchProducts(query);
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Search Results for "$query"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('No products found'))
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final product = results[index];
                      return ListTile(
                        title: Text(product.title),
                        subtitle: Text('\$${product.effectivePrice}'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/product/${product.id}');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
