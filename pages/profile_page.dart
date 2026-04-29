import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (!userProvider.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You are not logged in',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.push('/auth'),
                    child: const Text('Login / Sign Up'),
                  ),
                ],
              ),
            );
          }

          final user = userProvider.currentUser!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
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
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            user.role == UserRole.seller
                                ? Icons.store
                                : user.role == UserRole.admin
                                    ? Icons.admin_panel_settings
                                    : user.role == UserRole.superAdmin
                                        ? Icons.security
                                        : Icons.account_circle,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getRoleLabel(user.role),
                          style: TextStyle(
                            color: _getRoleColor(user.role),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      // Seller-specific info
                      if (user.role == UserRole.seller) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Store: ${user.storeName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.storeDescription ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Profile Menu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Buyer/Seller specific menu items
                      if (userProvider.isBuyer) ...[
                        _buildMenuTile(
                          icon: Icons.package,
                          title: 'My Orders',
                          subtitle: 'View order history',
                          onTap: () => context.push('/orders'),
                        ),
                        _buildMenuTile(
                          icon: Icons.location_on,
                          title: 'Addresses',
                          subtitle: 'Manage delivery addresses',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Address management coming soon'),
                              ),
                            );
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.payment,
                          title: 'Payment Methods',
                          subtitle: 'Manage payment options',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Payment methods coming soon'),
                              ),
                            );
                          },
                        ),
                      ] else if (userProvider.isSeller) ...[
                        _buildMenuTile(
                          icon: Icons.dashboard,
                          title: 'Seller Dashboard',
                          subtitle: 'Manage your store',
                          onTap: () => context.push('/seller-dashboard'),
                        ),
                        _buildMenuTile(
                          icon: Icons.inventory,
                          title: 'My Products',
                          subtitle: 'Manage your products',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Product management coming soon'),
                              ),
                            );
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.receipt_long,
                          title: 'Sales & Orders',
                          subtitle: 'View your sales',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sales management coming soon'),
                              ),
                            );
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.trending_up,
                          title: 'Analytics',
                          subtitle: 'View store analytics',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Analytics coming soon'),
                              ),
                            );
                          },
                        ),
                      ] else if (userProvider.isAdmin) ...[
                        _buildMenuTile(
                          icon: Icons.dashboard,
                          title: 'Admin Dashboard',
                          subtitle: 'Platform management',
                          onTap: () => context.push('/admin-dashboard'),
                        ),
                        _buildMenuTile(
                          icon: Icons.verified,
                          title: 'Verify Sellers',
                          subtitle: 'Review seller applications',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Seller verification coming soon'),
                              ),
                            );
                          },
                        ),
                      ] else if (userProvider.isSuperAdmin) ...[
                        _buildMenuTile(
                          icon: Icons.security,
                          title: 'SuperAdmin Console',
                          subtitle: 'Full platform control',
                          onTap: () => context.push('/superadmin-dashboard'),
                        ),
                        _buildMenuTile(
                          icon: Icons.people,
                          title: 'User Management',
                          subtitle: 'Manage all users',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('User management coming soon'),
                              ),
                            );
                          },
                        ),
                      ],

                      // Common menu items
                      _buildMenuTile(
                        icon: Icons.favorite,
                        title: 'Wishlist',
                        subtitle: 'Your saved items',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Wishlist coming soon'),
                            ),
                          );
                        },
                      ),
                      _buildMenuTile(
                        icon: Icons.settings,
                        title: 'Settings',
                        subtitle: 'Account preferences',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Settings coming soon'),
                            ),
                          );
                        },
                      ),
                      _buildMenuTile(
                        icon: Icons.info,
                        title: 'Help & Support',
                        subtitle: 'Contact us',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Help coming soon'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await userProvider.logout();
                        if (mounted) {
                          context.go('/');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logged out successfully'),
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
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

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepOrange),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.buyer:
        return 'Buyer';
      case UserRole.seller:
        return 'Seller';
      case UserRole.admin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'SuperAdmin';
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.buyer:
        return Colors.blue;
      case UserRole.seller:
        return Colors.green;
      case UserRole.admin:
        return Colors.orange;
      case UserRole.superAdmin:
        return Colors.red;
    }
  }
}
