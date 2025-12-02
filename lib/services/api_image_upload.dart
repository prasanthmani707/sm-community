// lib/services/api_image_upload.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiImageUpload {
  // Replace with your Lambda/API Gateway endpoint that returns presigned URL
  final String presignApiUrl = "https://vghfsqg1d6.execute-api.ap-southeast-1.amazonaws.com/image_upload";

  /// Calls API to get presigned upload URL
  /// Returns a map with 'uploadUrl' and 'fileUrl' or null on failure
  Future<Map<String, String>?> getPresignedUrl({
    required String userId,
    required String fileType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(presignApiUrl),
        body: jsonEncode({"userId": userId, "fileType": fileType}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode != 200) {
        print("ApiImageUpload.getPresignedUrl failed: ${response.statusCode} ${response.body}");
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['uploadUrl'] == null || data['fileUrl'] == null) {
        print("Api returned invalid body: ${response.body}");
        return null;
      }

      return {
        'uploadUrl': data['uploadUrl'] as String,
        'fileUrl': data['fileUrl'] as String,
      };
    } catch (e) {
      print("Error in ApiImageUpload.getPresignedUrl: $e");
      return null;
    }
  }
}