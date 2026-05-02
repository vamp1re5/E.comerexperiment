import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'services/firebase_service.dart';
import 'models/product.dart';
import 'models/cart.dart';
import 'models/user.dart';
import 'models/notification.dart';
import 'models/review.dart';
import 'models/wishlist.dart';
import 'models/return.dart';
import 'pages/home_page.dart';
import 'pages/product_listing_page.dart';
import 'pages/product_detail_page.dart';
import 'pages/cart_page.dart';
import 'pages/checkout_page.dart';
import 'pages/order_confirmation_page.dart';
import 'pages/authentication_page.dart';
import 'pages/profile_page.dart';
import 'pages/order_history_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/admin_dashboard_detail_page.dart';
import 'pages/category_browser_page.dart';
import 'pages/seller_dashboard_page.dart';
import 'pages/seller_order_management_page.dart';
import 'pages/notification_center_page.dart';
import 'pages/reviews_page.dart';
import 'pages/settings_page.dart';
import 'pages/help_page.dart';
import 'pages/wishlist_page.dart';
import 'pages/returns_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.initialize();
  await FirebaseService.instance.productProvider.loadProducts();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FirebaseService.instance.productProvider),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => ReturnProvider()),
      ],
      child: const ECommerceApp(),
    ),
  );
}

class ECommerceApp extends StatelessWidget {
  const ECommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final GoRouter router = GoRouter(
      refreshListenable: userProvider,
      redirect: (context, state) {
        final location = state.location;
        final loggedIn = userProvider.isLoggedIn;
        final isAdminRoute = location == '/admin' || location == '/admin-dashboard';
        final isSuperAdminRoute = location == '/superadmin-dashboard';

        if (!loggedIn && (isAdminRoute || isSuperAdminRoute)) {
          return '/auth';
        }

        if (loggedIn && isSuperAdminRoute && !userProvider.canAccessSuperAdminPanel) {
          return userProvider.canAccessAdminPanel ? '/admin-dashboard' : '/';
        }

        if (loggedIn && isAdminRoute && !userProvider.canAccessAdminPanel) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductListingPage(),
        ),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            final productId = state.pathParameters['id'];
            return ProductDetailPage(productId: productId ?? '');
          },
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoryBrowserPage(),
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const CartPage(),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutPage(),
        ),
        GoRoute(
          path: '/order-confirmation/:orderId',
          builder: (context, state) {
            final orderId = state.pathParameters['orderId'];
            return OrderConfirmationPage(orderId: orderId ?? '');
          },
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthenticationPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrderHistoryPage(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/admin-dashboard',
          builder: (context, state) => const AdminDashboardDetailPage(),
        ),
        GoRoute(
          path: '/seller-dashboard',
          builder: (context, state) => const SellerDashboardPage(),
        ),
        GoRoute(
          path: '/seller-products',
          builder: (context, state) => const SellerProductManagementPage(),
        ),
        GoRoute(
          path: '/seller-orders',
          builder: (context, state) => const SellerOrderManagementPage(),
        ),
        GoRoute(
          path: '/seller-payouts',
          builder: (context, state) => const SellerPayoutDashboardPage(),
        ),
        GoRoute(
          path: '/superadmin-dashboard',
          builder: (context, state) => const SuperAdminDashboardPage(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationCenterPage(),
        ),
        GoRoute(
          path: '/reviews/:productId',
          builder: (context, state) {
            final productId = state.pathParameters['productId'];
            return ReviewsPage(productId: productId ?? '');
          },
        ),
        GoRoute(
          path: '/wishlist',
          builder: (context, state) => const WishlistPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/help',
          builder: (context, state) => const HelpPage(),
        ),
        GoRoute(
          path: '/returns',
          builder: (context, state) => const ReturnsPage(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'E-Commerce Store',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
