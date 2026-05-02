import 'package:flutter/material.dart';

enum ReturnStatus {
  requested,
  approved,
  rejected,
  inTransit,
  received,
  refunded,
}

class Return {
  final String id;
  final String orderId;
  final String productId;
  final String reason;
  final String? description;
  final List<String>? images;
  final ReturnStatus status;
  final DateTime requestDate;
  final DateTime? processedDate;
  final double refundAmount;

  Return({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.reason,
    this.description,
    this.images,
    this.status = ReturnStatus.requested,
    required this.requestDate,
    this.processedDate,
    required this.refundAmount,
  });
}

class ReturnProvider extends ChangeNotifier {
  final List<Return> _returns = [
    Return(
      id: 'ret1',
      orderId: 'ORD-001',
      productId: '1',
      reason: 'Defective',
      description: 'Left speaker not working',
      status: ReturnStatus.approved,
      requestDate: DateTime.now().subtract(const Duration(days: 3)),
      processedDate: DateTime.now().subtract(const Duration(days: 2)),
      refundAmount: 59.99,
    ),
  ];

  List<Return> get allReturns => _returns;

  List<Return> getUserReturns(String userId) {
    // In real app, filter by user
    return _returns;
  }

  Return? getReturn(String returnId) {
    try {
      return _returns.firstWhere((r) => r.id == returnId);
    } catch (e) {
      return null;
    }
  }

  void requestReturn({
    required String orderId,
    required String productId,
    required String reason,
    String? description,
    List<String>? images,
    required double refundAmount,
  }) {
    _returns.add(
      Return(
        id: 'ret_${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderId,
        productId: productId,
        reason: reason,
        description: description,
        images: images,
        requestDate: DateTime.now(),
        refundAmount: refundAmount,
      ),
    );
    notifyListeners();
  }

  void updateReturnStatus(String returnId, ReturnStatus status) {
    try {
      final index = _returns.indexWhere((r) => r.id == returnId);
      if (index >= 0) {
        final ret = _returns[index];
        _returns[index] = Return(
          id: ret.id,
          orderId: ret.orderId,
          productId: ret.productId,
          reason: ret.reason,
          description: ret.description,
          images: ret.images,
          status: status,
          requestDate: ret.requestDate,
          processedDate: DateTime.now(),
          refundAmount: ret.refundAmount,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error updating return status: $e');
    }
  }
}
