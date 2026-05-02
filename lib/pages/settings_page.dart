import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _zipCodeController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().currentUser;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _zipCodeController = TextEditingController(text: user?.zipCode ?? '');
    _countryController = TextEditingController(text: user?.country ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(
          child: Text('Please log in to update your account settings.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Account Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _zipCodeController,
              decoration: const InputDecoration(labelText: 'Zip Code'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _countryController,
              decoration: const InputDecoration(labelText: 'Country'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                final updatedUser = User(
                  id: user.id,
                  email: user.email,
                  fullName: _fullNameController.text.trim(),
                  phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                  profileImage: user.profileImage,
                  address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
                  city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
                  zipCode: _zipCodeController.text.trim().isEmpty ? null : _zipCodeController.text.trim(),
                  country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
                  role: user.role,
                  storeName: user.storeName,
                  storeDescription: user.storeDescription,
                  isVerified: user.isVerified,
                  accountNumber: user.accountNumber,
                  bankName: user.bankName,
                  bankCountry: user.bankCountry,
                );

                try {
                  await userProvider.updateProfile(updatedUser);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account settings updated successfully.')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating settings: $e')),
                    );
                  }
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
