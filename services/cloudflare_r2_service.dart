import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CloudflareR2Service {
  CloudflareR2Service._();
  static final CloudflareR2Service instance = CloudflareR2Service._();

  String get _accessKeyId => dotenv.env['CLOUDFLARE_R2_ACCESS_KEY_ID'] ?? '';
  String get _secretAccessKey => dotenv.env['CLOUDFLARE_R2_SECRET_ACCESS_KEY'] ?? '';
  String get _bucketName => dotenv.env['CLOUDFLARE_R2_BUCKET_NAME'] ?? '';
  String get _endpoint => dotenv.env['CLOUDFLARE_R2_ENDPOINT']?.replaceAll(RegExp(r'/+$'), '') ?? '';

  Future<String> uploadObject(
    Uint8List bytes,
    String objectKey, {
    String contentType = 'application/octet-stream',
  }) async {
    if (_accessKeyId.isEmpty || _secretAccessKey.isEmpty || _endpoint.isEmpty || _bucketName.isEmpty) {
      throw Exception('Cloudflare R2 is not configured. Check your .env file.');
    }

    final now = DateTime.now().toUtc();
    final amzDate = _formatAmzDate(now);
    final dateStamp = _formatDateStamp(now);
    final host = Uri.parse(_endpoint).host;
    final objectPath = '$_bucketName/$objectKey';
    final requestUri = Uri.parse('$_endpoint/$objectPath');

    final payloadHash = sha256.convert(bytes).toString();
    final canonicalHeaders = 'host:$host\nx-amz-content-sha256:$payloadHash\nx-amz-date:$amzDate\n';
    final signedHeaders = 'host;x-amz-content-sha256;x-amz-date';
    final canonicalRequest = [
      'PUT',
      '/$objectPath',
      '',
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join('\n');

    final algorithm = 'AWS4-HMAC-SHA256';
    final credentialScope = '$dateStamp/auto/s3/aws4_request';
    final stringToSign = [
      algorithm,
      amzDate,
      credentialScope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');

    final signingKey = _getSignatureKey(_secretAccessKey, dateStamp, 'auto', 's3');
    final signature = Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

    final authorizationHeader =
        '$algorithm Credential=$_accessKeyId/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';

    final headers = {
      'Authorization': authorizationHeader,
      'x-amz-content-sha256': payloadHash,
      'x-amz-date': amzDate,
      'Content-Type': contentType,
    };

    final response = await http.put(requestUri, headers: headers, body: bytes);
    if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
      throw Exception('R2 upload failed: ${response.statusCode} ${response.body}');
    }

    return requestUri.toString();
  }

  List<int> _sign(List<int> key, String message) {
    return Hmac(sha256, key).convert(utf8.encode(message)).bytes;
  }

  List<int> _getSignatureKey(
      String key, String dateStamp, String regionName, String serviceName) {
    final kDate = _sign(utf8.encode('AWS4$key'), dateStamp);
    final kRegion = _sign(kDate, regionName);
    final kService = _sign(kRegion, serviceName);
    return _sign(kService, 'aws4_request');
  }

  String _formatAmzDate(DateTime date) {
    return date.toIso8601String().replaceAll(RegExp(r'[:-]|\.\d+'), '') + 'Z';
  }

  String _formatDateStamp(DateTime date) {
    return _formatAmzDate(date).substring(0, 8);
  }
}
