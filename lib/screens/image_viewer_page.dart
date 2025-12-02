import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageViewerPage extends StatelessWidget {
  final String imageUrl;
  final bool showDownload;

  const ImageViewerPage({
    super.key,
    required this.imageUrl,
    this.showDownload = false,
  });

  /// Download image and save to gallery folder
  Future<void> downloadImage(BuildContext context) async {
    // Request storage/gallery permission
    Future<bool> requestGalleryPermission() async {
      if (Platform.isAndroid) {
        if (await Permission.storage.isGranted) return true;
        if (await Permission.storage.request().isGranted) return true;
        // Android 13+ uses photos permission
        if (await Permission.photos.request().isGranted) return true;
      } else if (Platform.isIOS) {
        if (await Permission.photos.isGranted) return true;
        if (await Permission.photos.request().isGranted) return true;
      }
      return false;
    }

    bool allowed = await requestGalleryPermission();
    if (!allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied")),
      );
      return;
    }

    try {
      // Download image bytes
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) throw Exception("Failed to download image");

      Uint8List bytes = response.bodyBytes;

      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      String tempPath =
          "${tempDir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg";

      File tempFile = File(tempPath);
      await tempFile.writeAsBytes(bytes);

      // Save to Pictures/Softmania folder
      await _saveToGallery(tempFile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image saved to gallery")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to download image")),
      );
    }
  }

  /// Saves the file to Pictures/Softmania folder
  Future<void> _saveToGallery(File file) async {
    final String filename = file.path.split('/').last;

    Directory? picturesDir;
    if (Platform.isAndroid) {
      picturesDir = Directory("/storage/emulated/0/Pictures/Softmania");
    } else {
      picturesDir = await getApplicationDocumentsDirectory();
    }

    if (!await picturesDir.exists()) {
      await picturesDir.create(recursive: true);
    }

    final File newFile = File("${picturesDir.path}/$filename");
    await newFile.writeAsBytes(await file.readAsBytes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (showDownload)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => downloadImage(context),
            ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image, size: 80, color: Colors.red);
            },
          ),
        ),
      ),
    );
  }
}