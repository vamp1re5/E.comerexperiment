import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../models/product.dart';

class ReviewsPage extends StatefulWidget {
  final String productId;

  const ReviewsPage({super.key, required this.productId});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  bool _showWriteReview = false;
  double _selectedRating = 5;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews & Ratings'),
        elevation: 0,
      ),
      body: Consumer2<ReviewProvider, ProductProvider>(
        builder: (context, reviewProvider, productProvider, _) {
          final product = productProvider.getProductById(widget.productId);
          final reviews = reviewProvider.getProductReviews(widget.productId);
          final avgRating = reviewProvider.getAverageRating(widget.productId);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating Summary
                if (product != null)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              avgRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  Icons.star,
                                  color: index < avgRating.round()
                                      ? Colors.amber
                                      : Colors.grey[300],
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${reviews.length} reviews',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Write Review Button
                if (!_showWriteReview)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () =>
                            setState(() => _showWriteReview = true),
                        child: const Text('Write a Review'),
                      ),
                    ),
                  ),

                // Write Review Form
                if (_showWriteReview)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rate this product',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: List.generate(
                                5,
                                (index) => IconButton(
                                  icon: Icon(Icons.star),
                                  color: index < _selectedRating
                                      ? Colors.amber
                                      : Colors.grey[300],
                                  onPressed: () =>
                                      setState(() => _selectedRating = index + 1.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Review Title',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Your Review',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        setState(() => _showWriteReview = false),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () {
                                      reviewProvider.addReview(
                                        Review(
                                          id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
                                          productId: widget.productId,
                                          userId: 'current_user',
                                          userName: 'You',
                                          rating: _selectedRating,
                                          title: _titleController.text,
                                          description:
                                              _descriptionController.text,
                                          date: DateTime.now(),
                                        ),
                                      );
                                      _titleController.clear();
                                      _descriptionController.clear();
                                      setState(
                                          () => _showWriteReview = false);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Review submitted!'),
                                        ),
                                      );
                                    },
                                    child: const Text('Submit'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Reviews List
                if (reviews.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No reviews yet. Be the first to review!',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      review.userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          Icons.star,
                                          size: 16,
                                          color: i < review.rating.round()
                                              ? Colors.amber
                                              : Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  review.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(review.description),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      _formatDate(review.date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton.icon(
                                      icon: const Icon(Icons.thumb_up_outlined,
                                          size: 16),
                                      label: Text('${review.helpful}'),
                                      onPressed: () =>
                                          reviewProvider
                                              .markHelpful(review.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
