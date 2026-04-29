import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart';

class AdminDashboardDetailPage extends StatelessWidget {
  const AdminDashboardDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
                subtitle: '23 pending verifications',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Seller verification coming soon'),
                    ),
                  );
                },
              ),

              _buildAdminActionTile(
                icon: Icons.warning,
                title: 'Reported Content',
                subtitle: '8 reports to review',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report review coming soon'),
                    ),
                  );
                },
              ),

              _buildAdminActionTile(
                icon: Icons.payments,
                title: 'Manage Payments',
                subtitle: 'Payment processing & disputes',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment management coming soon'),
                    ),
                  );
                },
              ),

              _buildAdminActionTile(
                icon: Icons.people_outline,
                title: 'Manage Users',
                subtitle: 'View & manage all users',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User management coming soon'),
                    ),
                  );
                },
              ),

              _buildAdminActionTile(
                icon: Icons.settings,
                title: 'System Settings',
                subtitle: 'Configure platform settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('System settings coming soon'),
                    ),
                  );
                },
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
