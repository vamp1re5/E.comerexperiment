import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/user.dart';
import 'cloudflare_r2_service.dart';
import 'firebase_options.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final fb.FirebaseAuth auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final CloudflareR2Service r2 = CloudflareR2Service.instance;

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
