import '../models/message.dart';
import '../services/api_service.dart';

class MessageFetchRepository {
  final ApiService _apiService = ApiService();

  Future<List<Message>> fetchMessages(String userId) async {
    final messages = await _apiService.fetchMessages(userId);

    for (var msg in messages) {
      if (msg.replyTo != null) {
        final parent = messages.firstWhere(
          (m) => m.messageId == msg.replyTo,
          orElse: () => Message.empty(),
        );

        msg.replyMessage = parent;

        if (parent.messageId.isNotEmpty) {
          parent.replyCount += 1;
        }
      }
    }

    return messages
        .where((msg) => msg.threadId == null)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}
