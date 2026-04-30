import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/user.dart';
import '../models/product.dart';
import 'cloudflare_r2_service.dart';
import 'firebase_options.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final fb.FirebaseAuth auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final CloudflareR2Service r2 = CloudflareR2Service.instance;
  final ProductProvider productProvider = ProductProvider();

  Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  Future<User> login(String email, String password, UserRole role) async {
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await firestore.collection('users').doc(credential.user!.uid).get();
    if (!doc.exists) {
      throw Exception('Account does not exist. Please sign up or contact support.');
    }

    final user = User.fromMap(doc.data()!, doc.id);
    if (user.role != role) {
      throw Exception('Selected role does not match account role.');
    }

    return user;
  }

  Future<User> signup(
    String email,
    String password,
    String fullName,
    UserRole role, {
    String? storeName,
    String? storeDescription,
    String? accountNumber,
    String? bankName,
    String? bankCountry,
  }) async {
    if (role == UserRole.admin || role == UserRole.superAdmin) {
      throw Exception('Admin and SuperAdmin accounts must be created from the Firebase console.');
    }

    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = User(
      id: credential.user!.uid,
      email: email,
      fullName: fullName,
      role: role,
      storeName: storeName,
      storeDescription: storeDescription,
      isVerified: role == UserRole.seller ? false : null,
      accountNumber: accountNumber,
      bankName: bankName,
      bankCountry: bankCountry,
    );

    await firestore.collection('users').doc(user.id).set(user.toMap());
    return user;
  }

  Future<User?> getCurrentUser() async {
    final fb.User? current = auth.currentUser;
    if (current == null) return null;
    final doc = await firestore.collection('users').doc(current.uid).get();
    if (!doc.exists) return null;
    return User.fromMap(doc.data()!, doc.id);
  }

  Future<User> updateProfile(User updatedUser) async {
    await firestore.collection('users').doc(updatedUser.id).set(updatedUser.toMap());
    return updatedUser;
  }

  Future<void> updateUserRole(String userId, UserRole role) async {
    if (role == UserRole.superAdmin) {
      throw Exception('SuperAdmin accounts can only be created in the Firebase console.');
    }

    final userDoc = firestore.collection('users').doc(userId);
    final snapshot = await userDoc.get();
    if (!snapshot.exists) {
      throw Exception('User not found.');
    }

    await userDoc.update({'role': role.name});
  }

  Future<void> promoteUserToAdmin(String userId) async {
    final userDoc = firestore.collection('users').doc(userId);
    final snapshot = await userDoc.get();
    if (!snapshot.exists) {
      throw Exception('User not found.');
    }

    final data = snapshot.data();
    final currentRole = _roleFromString(data?['role'] as String? ?? 'buyer');
    if (currentRole == UserRole.superAdmin) {
      throw Exception('SuperAdmin accounts can only be created in the Firebase console.');
    }
    if (currentRole == UserRole.admin) {
      throw Exception('User is already an admin.');
    }

    await updateUserRole(userId, UserRole.admin);
  }

  Future<void> verifySeller(String userId) async {
    final userDoc = firestore.collection('users').doc(userId);
    final snapshot = await userDoc.get();
    if (!snapshot.exists) {
      throw Exception('Seller not found.');
    }

    final data = snapshot.data();
    if (_roleFromString(data?['role'] as String? ?? 'buyer') != UserRole.seller) {
      throw Exception('User is not a seller.');
    }

    await userDoc.update({'isVerified': true});
  }

  Future<void> suspendUser(String userId) async {
    final userDoc = firestore.collection('users').doc(userId);
    final snapshot = await userDoc.get();
    if (!snapshot.exists) {
      throw Exception('User not found.');
    }

    await userDoc.update({'isSuspended': true});
  }

  Future<void> deleteUserRecord(String userId) async {
    await firestore.collection('users').doc(userId).delete();
  }

  Future<void> resolveDispute(String disputeId) async {
    final disputeDoc = firestore.collection('disputes').doc(disputeId);
    final snapshot = await disputeDoc.get();
    if (!snapshot.exists) {
      throw Exception('Dispute not found.');
    }

    await disputeDoc.update({
      'status': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestPayout(String sellerId, double amount, {String method = 'bank_transfer'}) async {
    final payoutRef = firestore.collection('payouts').doc();
    await payoutRef.set({
      'sellerId': sellerId,
      'amount': amount,
      'status': 'processing',
      'method': method,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<User?> getSellerByStoreName(String storeName) async {
    final snapshot = await firestore
        .collection('users')
        .where('storeName', isEqualTo: storeName)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    return User.fromMap(data, snapshot.docs.first.id);
  }

  Future<String> uploadReceipt(
    Uint8List bytes,
    String fileName, {
    String contentType = 'application/pdf',
  }) async {
    final hasR2 = dotenv.env['CLOUDFLARE_R2_ACCESS_KEY_ID']?.isNotEmpty == true;
    if (hasR2) {
      return r2.uploadObject(bytes, 'receipts/$fileName', contentType: contentType);
    }

    final reference = storage.ref().child('receipts/$fileName');
    final snapshot = await reference.putData(bytes, SettableMetadata(contentType: contentType));
    return snapshot.ref.getDownloadURL();
  }
}
