// 📁 lib/helpers/message_helper.dart

import '../models/message.dart';

class MessageHelper {
  /// -------------------------------------------------------
  /// 1) Detect if message content is an image
  /// -------------------------------------------------------
  static bool isImageMessage(String text) {
    final lower = text.toLowerCase();
    return lower.endsWith(".jpg") ||
        lower.endsWith(".jpeg") ||
        lower.endsWith(".png") ||
        lower.endsWith(".gif") ||
        lower.contains("amazonaws.com"); // S3 URLs
  }

  static bool isImage(Message msg) => isImageMessage(msg.content);

  /// -------------------------------------------------------
  /// 2) Determine message type (text, image, or API-defined)
  /// -------------------------------------------------------
  static String getMessageType(Message msg) {
    if (isImage(msg)) return "image";
    if (msg.type.isNotEmpty) return msg.type;
    return "text";
  }

  /// -------------------------------------------------------
  /// 3) Permission rules: can the message be edited?
  /// -------------------------------------------------------
  static bool canEdit(Message msg) {
    // Image messages cannot be edited
    if (isImage(msg)) return false;

    // Only allow editing if message belongs to user
    return msg.isMe;
  }

  /// -------------------------------------------------------
  /// 4) Permission rules: can the message be deleted?
  /// -------------------------------------------------------
  static bool canDelete(Message msg) {
    // For now, only allow deleting own messages
    return msg.isMe;
  }

  /// -------------------------------------------------------
  /// 5) Permission rules: can the message be replied to?
  /// -------------------------------------------------------
  static bool canReply(Message msg) {
    return true; // everyone can reply
  }

  /// -------------------------------------------------------
  /// 6) Build Thread Page navigation arguments
  /// -------------------------------------------------------
  static Map<String, dynamic> buildThreadArguments(
      Message msg, String userId, String email) {
    return {
      "root": msg,
      "userId": userId,
      "email": email,
    };
  }

  /// -------------------------------------------------------
  /// 7) Helper to check if this message is parent thread
  /// -------------------------------------------------------
  static bool isRootThread(Message msg) {
    return msg.replyTo == null && msg.threadId == null;
  }

  /// -------------------------------------------------------
  /// 8) Format timestamp if needed (optional helper)
  /// -------------------------------------------------------
  static String formattedTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  /// -------------------------------------------------------
  /// 9) Copy message with updated replyCount safely
  /// -------------------------------------------------------
  static Message incrementReplyCount(Message msg) {
    return msg.copyWith(replyCount: msg.replyCount + 1);
  }
}
