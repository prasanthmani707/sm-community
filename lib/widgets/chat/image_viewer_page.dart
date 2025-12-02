import 'package:flutter/material.dart';

class ImageViewerPage extends StatelessWidget {
  final String imageUrl;
  final bool showDownload;

  const ImageViewerPage({super.key, required this.imageUrl, this.showDownload = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          if (showDownload)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // Implement download logic if needed
              },
            ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
