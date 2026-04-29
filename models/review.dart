import 'package:flutter/material.dart';

class Review {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final double rating;
  final String title;
  final String description;
  final int helpful;
  final DateTime date;
  final List<String>? images;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.title,
    required this.description,
    this.helpful = 0,
    required this.date,
    this.images,
  });
}

class ReviewProvider extends ChangeNotifier {
  final List<Review> _reviews = [
    Review(
      id: 'rev1',
      productId: '1',
      userId: 'user1',
      userName: 'John D.',
      rating: 5,
      title: 'Excellent headphones!',
      description: 'Great sound quality and comfortable. Highly recommended!',
      helpful: 23,
      date: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Review(
      id: 'rev2',
      productId: '1',
      userId: 'user2',
      userName: 'Sarah M.',
      rating: 4,
      title: 'Good value for money',
      description: 'Battery life could be better but overall satisfied.',
      helpful: 15,
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  List<Review> getProductReviews(String productId) {
    return _reviews.where((r) => r.productId == productId).toList();
  }

  double getAverageRating(String productId) {
    final reviews = getProductReviews(productId);
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<double>(0, (s, r) => s + r.rating);
    return sum / reviews.length;
  }

  void addReview(Review review) {
    _reviews.add(review);
    notifyListeners();
  }

  void deleteReview(String reviewId) {
    _reviews.removeWhere((r) => r.id == reviewId);
    notifyListeners();
  }

  void markHelpful(String reviewId) {
    try {
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index >= 0) {
        final review = _reviews[index];
        _reviews[index] = Review(
          id: review.id,
          productId: review.productId,
          userId: review.userId,
          userName: review.userName,
          rating: review.rating,
          title: review.title,
          description: review.description,
          helpful: review.helpful + 1,
          date: review.date,
          images: review.images,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error marking review as helpful: $e');
    }
  }
}
