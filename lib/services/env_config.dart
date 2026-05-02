import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static const String _firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String _firebaseAuthDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const String _firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String _firebaseStorageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const String _firebaseMessagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String _firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String _firebaseMeasurementId = String.fromEnvironment('FIREBASE_MEASUREMENT_ID');

  static const String _cloudflareR2AccessKeyId = String.fromEnvironment('CLOUDFLARE_R2_ACCESS_KEY_ID');
  static const String _cloudflareR2SecretAccessKey = String.fromEnvironment('CLOUDFLARE_R2_SECRET_ACCESS_KEY');
  static const String _cloudflareR2BucketName = String.fromEnvironment('CLOUDFLARE_R2_BUCKET_NAME');
  static const String _cloudflareR2Endpoint = String.fromEnvironment('CLOUDFLARE_R2_ENDPOINT');

  static String get firebaseApiKey => _firebaseApiKey.isNotEmpty ? _firebaseApiKey : dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAuthDomain => _firebaseAuthDomain.isNotEmpty ? _firebaseAuthDomain : dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get firebaseProjectId => _firebaseProjectId.isNotEmpty ? _firebaseProjectId : dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket => _firebaseStorageBucket.isNotEmpty ? _firebaseStorageBucket : dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseMessagingSenderId => _firebaseMessagingSenderId.isNotEmpty ? _firebaseMessagingSenderId : dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseAppId => _firebaseAppId.isNotEmpty ? _firebaseAppId : dotenv.env['FIREBASE_APP_ID'] ?? '';
  static String? get firebaseMeasurementId => _firebaseMeasurementId.isNotEmpty ? _firebaseMeasurementId : dotenv.env['FIREBASE_MEASUREMENT_ID'];

  static String get cloudflareR2AccessKeyId => _cloudflareR2AccessKeyId.isNotEmpty ? _cloudflareR2AccessKeyId : dotenv.env['CLOUDFLARE_R2_ACCESS_KEY_ID'] ?? '';
  static String get cloudflareR2SecretAccessKey => _cloudflareR2SecretAccessKey.isNotEmpty ? _cloudflareR2SecretAccessKey : dotenv.env['CLOUDFLARE_R2_SECRET_ACCESS_KEY'] ?? '';
  static String get cloudflareR2BucketName => _cloudflareR2BucketName.isNotEmpty ? _cloudflareR2BucketName : dotenv.env['CLOUDFLARE_R2_BUCKET_NAME'] ?? '';
  static String get cloudflareR2Endpoint => _cloudflareR2Endpoint.isNotEmpty ? _cloudflareR2Endpoint : dotenv.env['CLOUDFLARE_R2_ENDPOINT'] ?? '';

  static bool get hasR2Keys =>
      cloudflareR2AccessKeyId.isNotEmpty &&
      cloudflareR2SecretAccessKey.isNotEmpty &&
      cloudflareR2BucketName.isNotEmpty &&
      cloudflareR2Endpoint.isNotEmpty;
}
