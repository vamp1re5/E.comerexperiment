import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';

class AdminDashboardDetailPage extends StatelessWidget {
  const AdminDashboardDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (!userProvider.canAccessAdminPanel) {
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
                const Icon(Icons.lock, size: 80, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  'You do not have permission to access this panel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (userProvider.isSuperAdmin) {
                      context.go('/superadmin-dashboard');
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
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<UserProvider>().logout();
              context.go('/');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // KPI Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildKPICard(
                    title: 'Total Sales',
                    value: '\$124,450',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                  _buildKPICard(
                    title: 'Total Orders',
                    value: '2,340',
                    icon: Icons.shopping_cart,
                    color: Colors.blue,
                  ),
                  _buildKPICard(
                    title: 'Total Customers',
                    value: '12,030',
                    icon: Icons.people,
                    color: Colors.orange,
                  ),
                  _buildKPICard(
                    title: 'Active Sellers',
                    value: '560',
                    icon: Icons.store,
                    color: Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Admin Actions
              const Text(
                'Admin Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _buildAdminActionTile(
                icon: Icons.verified,
                title: 'Verify Sellers',
                subtitle: 'Pending seller approval',
                onTap: () => _showSellerVerificationDialog(context),
              ),

              _buildAdminActionTile(
                icon: Icons.warning,
                title: 'Reported Content',
                subtitle: 'Review flagged reports',
                onTap: () => _showReportDialog(context),
              ),

              _buildAdminActionTile(
                icon: Icons.payments,
                title: 'Manage Payments',
                subtitle: 'Review payment records',
                onTap: () => _showPaymentManagementDialog(context),
              ),

              _buildAdminActionTile(
                icon: Icons.people_outline,
                title: 'Manage Users',
                subtitle: 'View & manage all users',
                onTap: () => _showUserManagementDialog(context),
              ),

              _buildAdminActionTile(
                icon: Icons.settings,
                title: 'System Settings',
                subtitle: 'Configure platform settings',
                onTap: () => _showSystemSettingsDialog(context),
              ),

              const SizedBox(height: 32),

              // Recent Orders
              const Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Order ID')),
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Seller')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Text('ORD-001')),
                        const DataCell(Text('John Doe')),
                        const DataCell(Text('Tech Store')),
                        const DataCell(Text('\$99.99')),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('ORD-002')),
                        const DataCell(Text('Jane Smith')),
                        const DataCell(Text('Fashion Plus')),
                        const DataCell(Text('\$149.99')),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Processing',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                      ]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Manage Users'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: min(8, users.length),
                  itemBuilder: (context, index) {
                    final userData = users[index].data() as Map<String, dynamic>;
                    final role = userData['role'] as String? ?? 'buyer';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRoleColor(role),
                        child: Icon(_getRoleIcon(role), color: Colors.white),
                      ),
                      title: Text(userData['fullName'] ?? 'Unknown'),
                      subtitle: Text('${userData['email'] ?? ''} • ${role}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (userData['role'] == 'buyer' || userData['role'] == 'seller')
                            IconButton(
                              icon: const Icon(Icons.admin_panel_settings),
                              tooltip: 'Promote to Admin',
                              onPressed: () async {
                                try {
                                  await FirebaseService.instance.updateUserRole(
                                    users[index].id,
                                    UserRole.admin,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${userData['fullName'] ?? 'User'} promoted to Admin',
                                        ),
                                      ),
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
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete user record',
                            onPressed: () async {
                              try {
                                await FirebaseService.instance.deleteUserRecord(users[index].id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${userData['fullName'] ?? 'User'} deleted')),
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
                          ),
                        ],
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

  void _showSellerVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verify Sellers'),
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

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reported Content'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reports').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reports = snapshot.data!.docs;
                if (reports.isEmpty) {
                  return const Center(child: Text('No reported content found.'));
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

  void _showPaymentManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment Records'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('payments').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final payments = snapshot.data!.docs;
                if (payments.isEmpty) {
                  return const Center(child: Text('No payment records found.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: min(8, payments.length),
                  itemBuilder: (context, index) {
                    final payment = payments[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(payment['transactionId'] ?? 'Payment'),
                      subtitle: Text('\$${(payment['amount'] ?? 0.0).toString()} - ${payment['status'] ?? 'unknown'}'),
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

  void _showSystemSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('System Settings'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('system_config').doc('settings').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final maintenanceMode = data?['maintenanceMode'] ?? false;
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
                    Text('Current mode: ${maintenanceMode ? 'Maintenance' : 'Live'}'),
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

  Widget _buildKPICard({
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

  Widget _buildAdminActionTile({
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
}
