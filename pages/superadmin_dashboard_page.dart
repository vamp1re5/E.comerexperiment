import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart';

class SuperAdminDashboardPage extends StatelessWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SuperAdmin Dashboard'),
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
                'SuperAdmin Console',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Full platform control and management',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Critical Stats
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatCard(
                    title: 'Platform Revenue',
                    value: '\$524,450',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: 'Total Transactions',
                    value: '9,340',
                    icon: Icons.swap_horiz,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    title: 'Total Users',
                    value: '42,030',
                    icon: Icons.people,
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    title: 'System Health',
                    value: '99.8%',
                    icon: Icons.health_and_safety,
                    color: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // SuperAdmin Controls
              const Text(
                'Platform Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _buildControlTile(
                icon: Icons.admin_panel_settings,
                title: 'Manage Admins',
                subtitle: 'Create, edit, remove admin accounts',
                count: '12 Admins',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Admin management coming soon')),
                  );
                },
              ),

              _buildControlTile(
                icon: Icons.store,
                title: 'Manage Sellers',
                subtitle: 'Review & manage seller accounts',
                count: '560 Sellers',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seller management coming soon')),
                  );
                },
              ),

              _buildControlTile(
                icon: Icons.person,
                title: 'Manage Users',
                subtitle: 'User account & activity control',
                count: '42,030 Users',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User management coming soon')),
                  );
                },
              ),

              _buildControlTile(
                icon: Icons.policy,
                title: 'Policy Management',
                subtitle: 'Platform rules & agreements',
                count: '5 Policies',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Policy management coming soon')),
                  );
                },
              ),

              _buildControlTile(
                icon: Icons.security,
                title: 'Security Settings',
                subtitle: 'System security & encryption',
                count: 'Active',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Security settings coming soon')),
                  );
                },
              ),

              _buildControlTile(
                icon: Icons.analytics,
                title: 'Analytics & Reports',
                subtitle: 'Platform statistics & insights',
                count: '120+ Reports',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Analytics coming soon')),
                  );
                },
              ),

              _buildControlTile(
                icon: Icons.warning,
                title: 'Risk Management',
                subtitle: 'Fraud detection & dispute resolution',
                count: '8 Cases',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Risk management coming soon')),
                  );
                },
              ),

              _buildControlTile(
                icon: Icons.tune,
                title: 'System Configuration',
                subtitle: 'Advanced platform settings',
                count: 'Advanced',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('System config coming soon')),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Alerts
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  border: Border.all(color: Colors.amber[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.amber[700]),
                        const SizedBox(width: 12),
                        const Text(
                          'System Alerts',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• 23 seller verifications pending\n• 8 dispute cases awaiting review\n• Database backup completed successfully\n• 3 suspicious accounts flagged',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String count,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.deepOrange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.deepOrange),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              count,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Icon(Icons.arrow_forward, size: 16),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
