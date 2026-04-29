import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart';
import '../models/product.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<UserProvider>().logout();
              if (mounted) {
                context.go('/');
              }
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final seller = userProvider.currentUser;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Seller Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.store,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  seller?.storeName ?? 'My Store',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 16,
                                      color: (seller?.isVerified ?? false)
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      (seller?.isVerified ?? false)
                                          ? 'Verified Seller'
                                          : 'Pending Verification',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: (seller?.isVerified ?? false)
                                            ? Colors.green
                                            : Colors.orange,
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
                ),

                // Stats
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildStatCard(
                        title: 'Total Sales',
                        value: '\$8,950',
                        icon: Icons.trending_up,
                        color: Colors.green,
                      ),
                      _buildStatCard(
                        title: 'Orders',
                        value: '145',
                        icon: Icons.shopping_cart,
                        color: Colors.blue,
                      ),
                      _buildStatCard(
                        title: 'Products',
                        value: '42',
                        icon: Icons.inventory,
                        color: Colors.purple,
                      ),
                      _buildStatCard(
                        title: 'Rating',
                        value: '4.8★',
                        icon: Icons.star,
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.5,
                        children: [
                          _buildActionButton(
                            icon: Icons.add,
                            label: 'Add Product',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Add product feature coming soon'),
                                ),
                              );
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.manage_search,
                            label: 'Manage Products',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Manage products feature coming soon'),
                                ),
                              );
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.receipt_long,
                            label: 'View Orders',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('View orders feature coming soon'),
                                ),
                              );
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.settings,
                            label: 'Store Settings',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Store settings coming soon'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: Colors.deepOrange),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
