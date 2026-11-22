import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction.dart';
import '../models/sign.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  String baseUrl;
  ApiClient(this.baseUrl);

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  /// Sends base64 JPEG frames; the server extracts landmarks and classifies the sign.
  Future<Prediction> predictImages(List<String> jpegBase64) async {
    try {
      final r = await http
          .post(_u('/api/predict_images'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'images': jpegBase64}))
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      if (r.statusCode != 200) throw ApiException(body['error']?.toString() ?? 'Server error ${r.statusCode}');
      return Prediction.fromJson(body);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Cannot reach the server. Check the address in Settings.');
    }
  }

  Future<List<Sign>> getSigns() async {
    try {
      final r = await http.get(_u('/api/signs')).timeout(const Duration(seconds: 6));
      final list = jsonDecode(r.body) as List<dynamic>;
      return list.map((e) => Sign.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return Sign.fallback;
    }
  }

  Future<bool> health() async {
    try {
      final r = await http.get(_u('/api/health')).timeout(const Duration(seconds: 4));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
