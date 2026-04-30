import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../models/cart.dart';
import '../models/wishlist.dart';
import '../models/review.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        final product = productProvider.getProductById(widget.productId);

        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Product')),
            body: const Center(child: Text('Product not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Product Details'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Gallery
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 300,
                      color: Colors.grey[200],
                      child: Center(
                        child: Image.network(
                          product.images[_selectedImageIndex],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.primaries[int.parse(product.id) %
                                      Colors.primaries.length]
                                  .withOpacity(0.3),
                              child: const Center(
                                child: Icon(Icons.image, size: 64),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (product.isOnSale)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '-${product.discount.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Product Images
                if (product.images.length > 1)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: product.images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedImageIndex = index),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: _selectedImageIndex == index
                                      ? Border.all(
                                          color: Colors.deepOrange,
                                          width: 2,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.images[index],
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Product Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Rating & Reviews
                      Row(
                        children: [
                          Icon(Icons.star, size: 18, color: Colors.amber[700]),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '(${product.reviews} reviews)',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push('/reviews/${product.id}'),
                            child: const Text('See all'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Price
                      Row(
                        children: [
                          if (product.isOnSale)
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[600],
                              ),
                            ),
                          if (product.isOnSale)
                            const SizedBox(width: 12),
                          Text(
                            '\$${product.effectivePrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Seller Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Seller: ${product.seller}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(Icons.verified, color: Colors.blue),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: TextStyle(color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 16),

                      // Stock Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: product.stock > 0
                              ? Colors.green[50]
                              : Colors.red[50],
                          border: Border.all(
                            color: product.stock > 0
                                ? Colors.green
                                : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.stock > 0
                              ? '${product.stock} in stock'
                              : 'Out of stock',
                          style: TextStyle(
                            color:
                                product.stock > 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Quantity Selector
                      Row(
                        children: [
                          const Text('Quantity: '),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _quantity.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _quantity < product.stock
                                ? () => setState(() => _quantity++)
                                : null,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Consumer<WishlistProvider>(
                            builder: (context, wishlistProvider, _) {
                              final isInWishlist = wishlistProvider.wishlistItems
                                  .any((item) => item.id == product.id);
                              return IconButton(
                                icon: Icon(
                                  isInWishlist
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      isInWishlist ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  if (isInWishlist) {
                                    wishlistProvider
                                        .removeWishlistItem(product.id);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Removed from wishlist'),
                                      ),
                                    );
                                  } else {
                                    wishlistProvider.addWishlistItem(product);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Added to wishlist'),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                          Expanded(
                            child: FilledButton.icon(
                              icon: const Icon(Icons.shopping_cart),
                              label: const Text('Add to Cart'),
                              onPressed: product.stock > 0
                                  ? () {
                                      context.read<CartProvider>().addToCart(
                                            product,
                                            quantity: _quantity,
                                          );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${product.title} added to cart',
                                          ),
                                          duration:
                                              const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Buy Now Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: product.stock > 0
                              ? () {
                                  context.read<CartProvider>().addToCart(
                                        product,
                                        quantity: _quantity,
                                      );
                                  context.push('/checkout');
                                }
                              : null,
                          child: const Text('Buy Now'),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
