# E-Commerce Platform - Full Stack Flutter Application

A comprehensive multi-role e-commerce platform built with Flutter, inspired by AliExpress and Amazon. This application supports multiple user roles with distinct features for buyers, sellers, admins, and superadmins.

## 🎯 Platform Overview

This is a complete e-commerce ecosystem with role-based access control, featuring:
- **Buyers**: Shop for products, manage carts, checkout, and track orders
- **Sellers**: Manage stores, list products, view sales, and analytics
- **Admins**: Manage platform content, verify sellers, handle disputes
- **SuperAdmins**: Full platform control, user management, system configuration

## 📱 Core Features

### 🛍️ Buyer Features
- Browse products with filtering and sorting
- Search functionality across product catalog
- Product detail view with ratings and reviews
- Shopping cart management
- Multi-step checkout process
- Order history and tracking
- Wishlist (coming soon)
- Address management
- Multiple payment methods

### 🏪 Seller Features
- Store setup and profile creation
- Product management dashboard
- Sales analytics and reporting
- Order management system
- Rating and reviews monitoring
- Store verification status
- Commission tracking
- Seller store settings

### 👨‍💼 Admin Features
- Seller verification and approval
- Content moderation
- Dispute resolution
- User account management
- Payment processing oversight
- Reported content review
- Transaction management
- System monitoring

### 🔐 SuperAdmin Features
- Complete platform control
- Admin account management
- User and seller management
- Policy and rules configuration
- Security settings and encryption management
- Advanced analytics and reporting
- Fraud detection and risk management
- System configuration

## 🏗️ Project Structure

```
lib/
├── main.dart                           # App entry point and routing
├── models/
│   ├── product.dart                   # Product data model and provider
│   ├── cart.dart                      # Shopping cart provider
│   └── user.dart                      # User model with role enums
├── pages/
│   ├── home_page.dart                 # Dashboard with categories & featured products
│   ├── product_listing_page.dart      # Product catalog with filters
│   ├── product_detail_page.dart       # Detailed product view
│   ├── cart_page.dart                 # Shopping cart
│   ├── checkout_page.dart             # Multi-step checkout
│   ├── order_confirmation_page.dart   # Order success screen
│   ├── authentication_page.dart       # Login/signup with role selection
│   ├── profile_page.dart              # User profile (role-specific)
│   ├── order_history_page.dart        # Order tracking
│   ├── category_browser_page.dart     # Browse all categories
│   ├── admin_dashboard_page.dart      # Admin home
│   ├── admin_dashboard_detail_page.dart# Admin management
│   ├── seller_dashboard_page.dart     # Seller dashboard
│   └── superadmin_dashboard_page.dart # SuperAdmin console
├── widgets/
│   ├── product_card.dart              # Reusable product card
│   ├── search_bar.dart                # Search functionality
│   └── flash_sale_banner.dart         # Promotional banner
└── pubspec.yaml                       # Dependencies

```

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Navigation**: GoRouter
- **UI Components**: Material Design 3
- **HTTP Client**: (Ready for integration)
- **Local Storage**: (Ready for integration)

## 📦 Dependencies

```yaml
provider: ^6.0.0          # State management
go_router: ^13.0.0        # Navigation
intl: ^0.19.0             # Internationalization
cached_network_image: ^3.3.0  # Image caching
smooth_page_indicator: ^1.1.0 # Carousel pagination
flutter_staggered_grid_view: ^0.7.0  # Grid layouts
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode (for running on devices)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/vamp1re5/E.comerexperiment.git
   cd E.comerexperiment
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## 👥 User Roles & Access

### Role Selection During Authentication

Users can select their role during login or signup:

#### Buyer
- Default role for new users
- Access to shopping, orders, and wishlists
- Private shopping history

#### Seller
- Requires store name and description during signup
- Access to seller dashboard after account creation
- Verification pending until admin approves
- Can list and manage products

#### Admin (Login Only)
- Accessible only through login
- Select "Admin" role during login
- Access to admin dashboard
- Can verify sellers and manage content

#### SuperAdmin (Login Only)
- Highest level of access
- Select "SuperAdmin" role during login
- Full platform management and control

## 🔐 User Role Enums

```dart
enum UserRole {
  buyer,      // Regular customer
  seller,     // Store owner
  admin,      // Platform moderator
  superAdmin, // Platform administrator
}
```

## 📱 Key Routes

| Route | Page | Role |
|-------|------|------|
| `/` | Home Page | All |
| `/products` | Product Listing | All |
| `/product/:id` | Product Details | All |
| `/cart` | Shopping Cart | Buyer |
| `/checkout` | Checkout | Buyer |
| `/auth` | Authentication | All |
| `/profile` | User Profile | Logged-in users |
| `/orders` | Order History | Buyer |
| `/seller-dashboard` | Seller Dashboard | Seller |
| `/admin-dashboard` | Admin Dashboard | Admin |
| `/superadmin-dashboard` | SuperAdmin Console | SuperAdmin |

## 🔄 Authentication Flow

```
Login/Signup
    ↓
Select Role
    ↓
Enter Credentials
    ↓
Role-Based Redirect
├─ Buyer → Profile
├─ Seller → Seller Dashboard
├─ Admin → Admin Dashboard
└─ SuperAdmin → SuperAdmin Console
```

## 💼 Seller Workflow

1. **Signup** → Enter store name and description
2. **Pending Verification** → Await admin approval
3. **Access Dashboard** → After verification
4. **Add Products** → Manage inventory
5. **Track Sales** → Monitor orders and earnings
6. **View Analytics** → Track store performance

## 👮 Admin Workflow

1. **Login** → Select Admin role
2. **Access Dashboard** → View platform metrics
3. **Verify Sellers** → Review applications
4. **Manage Content** → Review reports
5. **Handle Disputes** → Resolve transactions

## 🔧 Configuration

All configuration is currently mock data in the models. The app is ready to integrate with:

- **Backend API**: REST or GraphQL
- **Authentication**: Firebase, Auth0, or custom backend
- **Database**: Firebase Firestore, Supabase, or SQL
- **Payment Gateway**: Stripe, PayPal, or other providers
- **Image Storage**: Firebase Storage or CDN

## 🎨 UI/UX Features

- **Material Design 3**: Modern, responsive interface
- **Adaptive Layouts**: Supports mobile and tablet
- **Dark Mode Ready**: Theme system in place
- **Smooth Animations**: Flash sale banner animations
- **Responsive Grid**: Dynamic product grid based on screen size

## 📊 Data Models

### Product
```dart
- id: String
- title: String
- description: String
- price: double
- rating: double
- reviews: int
- category: String
- images: List<String>
- stock: int
- seller: String
- isFeatured: bool
- isOnSale: bool
- discountPrice: double?
```

### User
```dart
- id: String
- email: String
- fullName: String
- role: UserRole
- phone: String?
- address: String?
- city: String?
- zipCode: String?
- country: String?
- storeName: String? (Seller)
- storeDescription: String? (Seller)
- isVerified: bool? (Seller)
```

### Order
```dart
- id: String
- orderDate: DateTime
- totalAmount: double
- items: List<OrderItem>
- status: String
- shippingAddress: String
```

## 🧪 Testing

The app currently uses mock data for demonstration. To add real data:

1. Implement API calls in service layer
2. Update providers to fetch from backend
3. Add error handling and loading states
4. Implement local caching with Hive or SQLite

## 🚀 Future Enhancements

- [ ] Real-time notifications
- [ ] Advanced search with filters
- [ ] Product recommendations
- [ ] Seller chat/messaging
- [ ] Wishlist synchronization
- [ ] Wallet/credit system
- [ ] Subscription plans
- [ ] Loyalty programs
- [ ] Mobile wallet integration
- [ ] Advanced analytics dashboard
- [ ] AI-powered search
- [ ] Video product showcase
- [ ] Live seller chat
- [ ] Returns and refunds management

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 📞 Support

For support, contact: support@ecommerceapp.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Provider package for state management
- Material Design for UI guidelines
- Inspired by AliExpress and Amazon

---

**Version**: 1.0.0  
**Last Updated**: April 2026  
**Status**: Active Development