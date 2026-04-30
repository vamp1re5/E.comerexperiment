import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

import '../models/user.dart';
import '../services/firebase_service.dart';

class SuperAdminDashboardPage extends StatefulWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  State<SuperAdminDashboardPage> createState() => _SuperAdminDashboardPageState();
}

class _SuperAdminDashboardPageState extends State<SuperAdminDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Stream<QuerySnapshot> _usersStream;
  late Stream<QuerySnapshot> _ordersStream;
  late Stream<QuerySnapshot> _productsStream;
  late Stream<QuerySnapshot> _disputesStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize streams for real-time data
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
    _ordersStream = FirebaseFirestore.instance.collection('orders').snapshots();
    _productsStream = FirebaseFirestore.instance.collection('products').snapshots();
    _disputesStream = FirebaseFirestore.instance
        .collection('disputes')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (!userProvider.canAccessSuperAdminPanel) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security, size: 80, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  'SuperAdmin access is restricted to SuperAdmin users only.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (userProvider.canAccessAdminPanel) {
                      context.go('/admin-dashboard');
                    } else {
                      context.go('/');
                    }
                  },
                  child: const Text('Return Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade700,
              Colors.purple.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Super Admin Console',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ultimate Platform Control',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await context.read<UserProvider>().logout();
                        if (mounted) {
                          context.go('/');
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      tooltip: 'Logout',
                    ),
                  ],
                ),
              ),

              // Stats Cards
              Container(
                height: 120,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _usersStream,
                  builder: (context, usersSnapshot) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: _ordersStream,
                      builder: (context, ordersSnapshot) {
                        return StreamBuilder<QuerySnapshot>(
                          stream: _productsStream,
                          builder: (context, productsSnapshot) {
                            int totalUsers = usersSnapshot.data?.docs.length ?? 0;
                            int totalOrders = ordersSnapshot.data?.docs.length ?? 0;
                            int totalProducts = productsSnapshot.data?.docs.length ?? 0;

                            // Calculate revenue
                            double totalRevenue = 0;
                            if (ordersSnapshot.hasData) {
                              for (var doc in ordersSnapshot.data!.docs) {
                                final data = doc.data() as Map<String, dynamic>;
                                totalRevenue += (data['totalAmount'] ?? 0.0) as double;
                              }
                            }

                            return ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildStatCard(
                                  'Total Revenue',
                                  '\$${totalRevenue.toStringAsFixed(0)}',
                                  Icons.attach_money,
                                  Colors.green,
                                ),
                                _buildStatCard(
                                  'Total Users',
                                  totalUsers.toString(),
                                  Icons.people,
                                  Colors.blue,
                                ),
                                _buildStatCard(
                                  'Total Orders',
                                  totalOrders.toString(),
                                  Icons.shopping_cart,
                                  Colors.orange,
                                ),
                                _buildStatCard(
                                  'Total Products',
                                  totalProducts.toString(),
                                  Icons.inventory,
                                  Colors.purple,
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  tabs: const [
                    Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
                    Tab(text: 'Users', icon: Icon(Icons.people)),
                    Tab(text: 'Management', icon: Icon(Icons.admin_panel_settings)),
                    Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDashboardTab(),
                      _buildUsersTab(),
                      _buildManagementTab(),
                      _buildAnalyticsTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Quick Actions Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
            children: [
              _buildQuickActionCard(
                Icons.verified_user,
                'Verify Sellers',
                Colors.green,
                () => _showSellerVerificationDialog(),
              ),
              _buildQuickActionCard(
                Icons.report_problem,
                'Handle Disputes',
                Colors.red,
                () => _showDisputesDialog(),
              ),
              _buildQuickActionCard(
                Icons.security,
                'Security Audit',
                Colors.blue,
                () => _showSecurityAuditDialog(),
              ),
              _buildQuickActionCard(
                Icons.backup,
                'System Backup',
                Colors.purple,
                () => _performSystemBackup(),
              ),
              _buildQuickActionCard(
                Icons.tune,
                'System Config',
                Colors.orange,
                () => _showSystemConfigDialog(),
              ),
              _buildQuickActionCard(
                Icons.analytics,
                'Generate Report',
                Colors.teal,
                () => _generateSystemReport(),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('activity_logs')
                .orderBy('timestamp', descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final activities = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index].data() as Map<String, dynamic>;
                  final timestamp = (activity['timestamp'] as Timestamp?)?.toDate();

                  return ListTile(
                    leading: Icon(
                      _getActivityIcon(activity['type']),
                      color: _getActivityColor(activity['type']),
                    ),
                    title: Text(activity['description'] ?? 'Unknown activity'),
                    subtitle: Text(
                      timestamp != null
                          ? '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'
                          : 'Unknown time',
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        // Group users by role
        final buyers = users.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['role'] == 'buyer';
        }).toList();

        final sellers = users.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['role'] == 'seller';
        }).toList();

        final admins = users.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['role'] == 'admin' || data['role'] == 'superAdmin';
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // User Role Cards
              Row(
                children: [
                  Expanded(
                    child: _buildUserRoleCard('Buyers', buyers.length, Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUserRoleCard('Sellers', sellers.length, Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUserRoleCard('Admins', admins.length, Colors.red),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // User Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showCreateUserDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Create User'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showBulkUserActions(),
                      icon: const Icon(Icons.more_vert),
                      label: const Text('Bulk Actions'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Recent Users
              const Text(
                'Recent Users',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: min(10, users.length),
                itemBuilder: (context, index) {
                  final userDoc = users[index];
                  final userData = userDoc.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRoleColor(userData['role']),
                        child: Icon(
                          _getRoleIcon(userData['role']),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(userData['fullName'] ?? 'Unknown'),
                      subtitle: Text(userData['email'] ?? ''),
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) => _handleUserAction(action, userDoc.id, userData),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'view', child: Text('View Details')),
                          const PopupMenuItem(value: 'edit', child: Text('Edit User')),
                          if (userData['role'] != 'admin' && userData['role'] != 'superAdmin')
                            const PopupMenuItem(value: 'promote', child: Text('Promote to Admin')),
                          const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildManagementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Management Tools
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildManagementCard(
                'Seller Verification',
                'Review & approve sellers',
                Icons.verified_user,
                Colors.green,
                () => _showSellerVerificationDialog(),
              ),
              _buildManagementCard(
                'Dispute Resolution',
                'Handle customer disputes',
                Icons.gavel,
                Colors.red,
                () => _showDisputesDialog(),
              ),
              _buildManagementCard(
                'Content Moderation',
                'Review reported content',
                Icons.report,
                Colors.orange,
                () => _showContentModerationDialog(),
              ),
              _buildManagementCard(
                'Payment Settings',
                'Configure payment options',
                Icons.payment,
                Colors.blue,
                () => _showPaymentSettingsDialog(),
              ),
              _buildManagementCard(
                'Platform Policies',
                'Update terms & policies',
                Icons.policy,
                Colors.purple,
                () => _showPolicyManagementDialog(),
              ),
              _buildManagementCard(
                'System Maintenance',
                'Database & server tasks',
                Icons.build,
                Colors.teal,
                () => _showSystemMaintenanceDialog(),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Pending Tasks
          const Text(
            'Pending Tasks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          StreamBuilder<QuerySnapshot>(
            stream: _disputesStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final disputes = snapshot.data!.docs;

              return Column(
                children: disputes.map((dispute) {
                  final data = dispute.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text('Dispute: ${data['title'] ?? 'Unknown'}'),
                      subtitle: Text('Order: ${data['orderId'] ?? 'Unknown'}'),
                      trailing: ElevatedButton(
                        onPressed: () => _resolveDispute(dispute.id),
                        child: const Text('Review'),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics & Insights',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Analytics Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildAnalyticsCard(
                'Revenue Trends',
                'View revenue analytics',
                Icons.trending_up,
                Colors.green,
              ),
              _buildAnalyticsCard(
                'User Growth',
                'User registration trends',
                Icons.people,
                Colors.blue,
              ),
              _buildAnalyticsCard(
                'Order Analytics',
                'Order patterns & insights',
                Icons.shopping_cart,
                Colors.orange,
              ),
              _buildAnalyticsCard(
                'Performance Metrics',
                'System performance data',
                Icons.speed,
                Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Generate Reports
          const Text(
            'Generate Reports',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _generateRevenueReport(),
                icon: const Icon(Icons.attach_money),
                label: const Text('Revenue Report'),
              ),
              ElevatedButton.icon(
                onPressed: () => _generateUserReport(),
                icon: const Icon(Icons.people),
                label: const Text('User Report'),
              ),
              ElevatedButton.icon(
                onPressed: () => _generateOrderReport(),
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Order Report'),
              ),
              ElevatedButton.icon(
                onPressed: () => _generateSystemReport(),
                icon: const Icon(Icons.analytics),
                label: const Text('System Report'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserRoleCard(String title, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'user_registered':
        return Icons.person_add;
      case 'order_placed':
        return Icons.shopping_cart;
      case 'seller_verified':
        return Icons.verified;
      case 'dispute_created':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'user_registered':
        return Colors.blue;
      case 'order_placed':
        return Colors.green;
      case 'seller_verified':
        return Colors.purple;
      case 'dispute_created':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String? role) {
    switch (role) {
      case 'buyer':
        return Icons.shopping_bag;
      case 'seller':
        return Icons.store;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'superAdmin':
        return Icons.security;
      default:
        return Icons.person;
    }
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'buyer':
        return Colors.blue;
      case 'seller':
        return Colors.green;
      case 'admin':
        return Colors.red;
      case 'superAdmin':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Action handlers
  void _showSellerVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seller Verification'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'seller')
                  .where('isVerified', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final sellers = snapshot.data!.docs;
                if (sellers.isEmpty) {
                  return const Center(child: Text('No sellers pending verification.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: sellers.length,
                  itemBuilder: (context, index) {
                    final sellerData = sellers[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(sellerData['fullName'] ?? 'Seller'),
                      subtitle: Text(sellerData['email'] ?? ''),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          try {
                            await FirebaseService.instance.verifySeller(sellers[index].id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${sellerData['fullName'] ?? 'Seller'} verified')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('Verify'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showDisputesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dispute Resolution'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('disputes')
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final disputes = snapshot.data!.docs;
                if (disputes.isEmpty) {
                  return const Center(child: Text('No pending disputes found.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: disputes.length,
                  itemBuilder: (context, index) {
                    final disputeData = disputes[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(disputeData['title'] ?? 'Dispute'),
                      subtitle: Text(disputeData['description'] ?? ''),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          try {
                            await FirebaseService.instance.resolveDispute(disputes[index].id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Dispute resolved')), 
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('Resolve'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showSecurityAuditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Security Audit'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('security_audits').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final audits = snapshot.data!.docs;
                if (audits.isEmpty) {
                  return const Center(child: Text('No security audit records available.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: min(8, audits.length),
                  itemBuilder: (context, index) {
                    final audit = audits[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(audit['title'] ?? 'Audit record'),
                      subtitle: Text(audit['summary'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _performSystemBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backing up platform data...')),
    );
  }

  void _showSystemConfigDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('System Configuration'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('system_config').doc('settings').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final settings = snapshot.data!.data() as Map<String, dynamic>?;
                final maintenanceMode = settings?['maintenanceMode'] ?? false;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('Maintenance Mode'),
                      value: maintenanceMode,
                      onChanged: (value) async {
                        await FirebaseFirestore.instance.collection('system_config').doc('settings').set(
                          {
                            'maintenanceMode': value,
                            'updatedAt': FieldValue.serverTimestamp(),
                          },
                          SetOptions(merge: true),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('Platform is currently ${maintenanceMode ? 'in maintenance' : 'live'}.'),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _generateSystemReport() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Generate Report'),
          content: const Text('System report requested. Check activity logs for results.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateUserDialog() {
    final emailController = TextEditingController();
    UserRole selectedRole = UserRole.buyer;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create / Promote User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Existing user email',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: UserRole.buyer, child: Text('Buyer')),
                  DropdownMenuItem(value: UserRole.seller, child: Text('Seller')),
                  DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedRole = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter an email address.')),
                  );
                  return;
                }

                final snapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: email)
                    .limit(1)
                    .get();

                if (snapshot.docs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No existing user found for that email.')),
                  );
                  return;
                }

                try {
                  await FirebaseService.instance.updateUserRole(snapshot.docs.first.id, selectedRole);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User promoted to ${selectedRole.label}.')),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showBulkUserActions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bulk User Actions'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allUsers = snapshot.data!.docs;
                final pendingSellers = allUsers.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['role'] == 'seller' && data['isVerified'] == false;
                }).toList();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total users: ${allUsers.length}'),
                    const SizedBox(height: 8),
                    Text('Pending seller verifications: ${pendingSellers.length}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: pendingSellers.isEmpty
                          ? null
                          : () async {
                              for (final seller in pendingSellers) {
                                await FirebaseService.instance.verifySeller(seller.id);
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('All pending sellers verified.')),
                                );
                              }
                            },
                      child: const Text('Verify All Pending Sellers'),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleUserAction(String action, String userId, Map<String, dynamic> userData) async {
    switch (action) {
      case 'view':
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(userData['fullName'] ?? 'User Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${userData['email'] ?? 'N/A'}'),
                  Text('Role: ${userData['role'] ?? 'N/A'}'),
                  if (userData['storeName'] != null) Text('Store: ${userData['storeName']}'),
                  if (userData['isVerified'] != null) Text('Verified: ${userData['isVerified']}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
        break;
      case 'edit':
        _showEditUserDialog(userId, userData);
        break;
      case 'promote':
        try {
          await FirebaseService.instance.updateUserRole(userId, UserRole.admin);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${userData['fullName'] ?? 'User'} promoted to Admin')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
        break;
      case 'suspend':
        try {
          await FirebaseService.instance.suspendUser(userId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${userData['fullName'] ?? 'User'} suspended')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
        break;
      case 'delete':
        try {
          await FirebaseService.instance.deleteUserRecord(userId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${userData['fullName'] ?? 'User'} deleted')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action "$action" is not available yet.')),
        );
    }
  }

  void _showEditUserDialog(String userId, Map<String, dynamic> userData) {
    final nameController = TextEditingController(text: userData['fullName'] as String?);
    final roleValue = userData['role'] as String? ?? 'buyer';
    UserRole selectedRole = UserRole.values.firstWhere(
      (role) => role.name == roleValue,
      orElse: () => UserRole.buyer,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: UserRole.buyer, child: Text('Buyer')),
                  DropdownMenuItem(value: UserRole.seller, child: Text('Seller')),
                  DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
                ],
                onChanged: (value) => selectedRole = value ?? selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('users').doc(userId).update({
                    'fullName': nameController.text.trim(),
                    'role': selectedRole.name,
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User updated successfully')),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showContentModerationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Content Moderation'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('content_reports').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reports = snapshot.data!.docs;
                if (reports.isEmpty) {
                  return const Center(child: Text('No content moderation reports.'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: min(8, reports.length),
                  itemBuilder: (context, index) {
                    final report = reports[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(report['title'] ?? 'Report'),
                      subtitle: Text(report['description'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment Settings'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('payment_settings').doc('default').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final settings = snapshot.data!.data() as Map<String, dynamic>?;
                return Text(settings != null
                    ? 'Current payment settings loaded.'
                    : 'No payment settings configured.');
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showPolicyManagementDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Policy Management'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('policies').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final policies = snapshot.data!.docs;
                if (policies.isEmpty) {
                  return const Center(child: Text('No policies configured.'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: min(8, policies.length),
                  itemBuilder: (context, index) {
                    final policy = policies[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(policy['title'] ?? 'Policy'),
                      subtitle: Text(policy['summary'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showSystemMaintenanceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('System Maintenance'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('system_config').doc('maintenance').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                return Text(data != null
                    ? 'Maintenance mode is ${data['active'] == true ? 'active' : 'inactive'}.'
                    : 'No maintenance settings configured.');
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _resolveDispute(String disputeId) async {
    try {
      await FirebaseService.instance.resolveDispute(disputeId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispute resolved successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resolving dispute: $e')),
      );
    }
  }

  void _generateRevenueReport() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Revenue Report'),
          content: const Text('Revenue report generation triggered. Check analytics for updates.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _generateUserReport() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('User Report'),
          content: const Text('User report generation triggered. Review user analytics for details.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _generateOrderReport() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Order Report'),
          content: const Text('Order report generation triggered. Check order analytics for details.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
