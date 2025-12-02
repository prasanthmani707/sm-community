import 'package:flutter/material.dart';
import '../../models/message.dart';

class ReplyBanner extends StatelessWidget {
  final Message? replyingTo;
  final VoidCallback onCancel;

  const ReplyBanner({super.key, this.replyingTo, required this.onCancel});

  bool isImageMessage(String text) {
    final lower = text.toLowerCase();
    return lower.endsWith(".jpg") ||
        lower.endsWith(".jpeg") ||
        lower.endsWith(".png") ||
        lower.endsWith(".gif") ||
        lower.contains("amazonaws.com");
  }

  @override
  Widget build(BuildContext context) {
    if (replyingTo == null) return const SizedBox.shrink();

    final isImage = isImageMessage(replyingTo!.content);

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: isImage
                ? Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          replyingTo!.content,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  )
                : Text(
                    replyingTo!.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
