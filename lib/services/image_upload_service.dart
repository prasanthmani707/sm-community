import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'api_image_upload.dart';

class ImageUploadService {
  final _picker = ImagePicker();
  final _api = ApiImageUpload();

  Future<String?> pickAndUpload({required String userId}) async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return null;

      final file = File(picked.path);
      final fileType = picked.path.split('.').last;

      final presign = await _api.getPresignedUrl(
        userId: userId,
        fileType: fileType,
      );

      if (presign == null) return null;

      final bytes = await file.readAsBytes();
      final uploadResponse = await http.put(
        Uri.parse(presign['uploadUrl']!),
        body: bytes,
        headers: {"Content-Type": "image/$fileType"},
      );

      if (uploadResponse.statusCode == 200) {
        return presign['fileUrl'];
      }
      return null;
    } catch (e) {
      print("ImageUploadService error: $e");
      return null;
    }
  }
}