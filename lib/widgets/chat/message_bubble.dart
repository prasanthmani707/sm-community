import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../common/rounded_container.dart';
import '../../utils/time_helper.dart';
import 'image_viewer_page.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final void Function(Offset position) onLongPress;
  final VoidCallback? onOpenThread;
  final bool isSelected;

  const MessageBubble({
    super.key,
    required this.message,
    required this.onLongPress,
    this.onOpenThread,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final isImage = message.type == 'image' || message.content.contains(RegExp(r'\.(jpg|jpeg|png|gif)$', caseSensitive: false));

    return GestureDetector(
      onLongPressStart: (details) => onLongPress(details.globalPosition),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe)
              CircleAvatar(
                radius: 18,
                child: Text(message.userId[0].toUpperCase()),
              ),
            if (!isMe) const SizedBox(width: 8),
            Flexible(
              child: RoundedContainer(
                color: isSelected
                    ? Colors.lightBlueAccent.withOpacity(0.3)
                    : (isMe ? Colors.green : Colors.grey[300]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Text(
                        message.userId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    if (!isMe) const SizedBox(height: 4),
                    if (message.replyMessage != null)
                      RoundedContainer(
                        padding: const EdgeInsets.all(6),
                        color: Colors.black12,
                        child: Text(
                          message.replyMessage!.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isMe ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    if (message.replyMessage != null) const SizedBox(height: 6),
                    if (isImage)
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImageViewerPage(
                              imageUrl: message.content,
                              showDownload: !isMe,
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            message.content,
                            width: 220,
                            height: 220,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                    ? child
                                    : SizedBox(
                                        width: 220,
                                        height: 220,
                                        child: const Center(
                                            child: CircularProgressIndicator()),
                                      ),
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              size: 90,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    if (!isImage)
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 16,
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          TimeHelper.formatChatTime(
                              DateTime.fromMillisecondsSinceEpoch(message.timestamp)),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        if (message.isEdited)
                          Text(
                            " (edited)",
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe ? Colors.white70 : Colors.black54,
                            ),
                          ),
                      ],
                    ),
                    if (message.replyCount > 0)
                      GestureDetector(
                        onTap: onOpenThread,
                        child: Text(
                          "View Thread (${message.replyCount})",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isMe ? Colors.white : Colors.blue),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
