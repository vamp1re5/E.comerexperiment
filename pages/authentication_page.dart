import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  bool _isLogin = true;
  UserRole _selectedRole = UserRole.buyer;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  late TextEditingController _storeNameController;
  late TextEditingController _storeDescController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankCountryController;
  late TextEditingController _accountNumberController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _storeNameController = TextEditingController();
    _storeDescController = TextEditingController();
    _bankNameController = TextEditingController();
    _bankCountryController = TextEditingController();
    _accountNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _storeNameController.dispose();
    _storeDescController.dispose();
    _bankNameController.dispose();
    _bankCountryController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                _isLogin ? 'Welcome Back!' : 'Create Account',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin
                    ? 'Sign in to your account to continue'
                    : 'Sign up to start ${_selectedRole == UserRole.seller ? 'selling' : 'shopping'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Role Selection
              Text(
                'Select Role:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Buyer'),
                    selected: _selectedRole == UserRole.buyer,
                    onSelected: (_) =>
                        setState(() => _selectedRole = UserRole.buyer),
                  ),
                  FilterChip(
                    label: const Text('Seller'),
                    selected: _selectedRole == UserRole.seller,
                    onSelected: (_) =>
                        setState(() => _selectedRole = UserRole.seller),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (!_isLogin)
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              if (!_isLogin) const SizedBox(height: 16),

              // Email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),

              // Seller-specific fields
              if (!_isLogin && _selectedRole == UserRole.seller) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _storeNameController,
                  decoration: const InputDecoration(
                    labelText: 'Store Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.store),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _storeDescController,
                  decoration: const InputDecoration(
                    labelText: 'Store Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bankNameController,
                  decoration: const InputDecoration(
                    labelText: 'Bank Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _accountNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Account Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bankCountryController,
                  decoration: const InputDecoration(
                    labelText: 'Bank Country',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.public),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Login/Sign Up Button
              FilledButton(
                onPressed: _isLoading ? null : _handleAuth,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(_isLogin ? 'Login' : 'Sign Up'),
              ),

              const SizedBox(height: 16),

              if (_isLogin)
                TextButton(
                  onPressed: () => context.push('/auth'),
                  child: const Text('Forgot Password?'),
                ),

              const SizedBox(height: 32),

              // Toggle Between Login and Sign Up
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin
                          ? "Don't have an account? "
                          : 'Already have an account? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _isLogin = !_isLogin);
                        _emailController.clear();
                        _passwordController.clear();
                        _nameController.clear();
                        _storeNameController.clear();
                        _storeDescController.clear();
                        _bankNameController.clear();
                        _bankCountryController.clear();
                        _accountNumberController.clear();
                      },
                      child: Text(_isLogin ? 'Sign Up' : 'Login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await context.read<UserProvider>().login(
          _emailController.text,
          _passwordController.text,
          _selectedRole,
        );
      } else {
        if (_nameController.text.isEmpty) {
          throw Exception('Please enter your name');
        }
        if (_selectedRole == UserRole.seller &&
            (_storeNameController.text.isEmpty ||
                _storeDescController.text.isEmpty)) {
          throw Exception('Please fill in store details');
        }

        await context.read<UserProvider>().signup(
              _emailController.text,
              _passwordController.text,
              _nameController.text,
              _selectedRole,
              storeName: _selectedRole == UserRole.seller
                  ? _storeNameController.text
                  : null,
              storeDescription: _selectedRole == UserRole.seller
                  ? _storeDescController.text
                  : null,
              accountNumber: _selectedRole == UserRole.seller
                  ? _accountNumberController.text
                  : null,
              bankName: _selectedRole == UserRole.seller
                  ? _bankNameController.text
                  : null,
              bankCountry: _selectedRole == UserRole.seller
                  ? _bankCountryController.text
                  : null,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isLogin ? 'Login successful' : 'Account created successfully',
            ),
          ),
        );
        
        // Route based on role
        final userProvider = context.read<UserProvider>();
        if (userProvider.isSeller) {
          context.go('/seller-dashboard');
        } else if (userProvider.isAdmin) {
          context.go('/admin-dashboard');
        } else if (userProvider.isSuperAdmin) {
          context.go('/superadmin-dashboard');
        } else {
          context.go('/profile');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
