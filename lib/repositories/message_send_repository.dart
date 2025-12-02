import '../services/api_service.dart';

class MessageSendRepository {
  final ApiService _apiService = ApiService();

  Future<void> send({
    required String userId,
    required String email,
    required String content,
    String? replyTo,
    String? threadId,
  }) {
    return _apiService.sendMessage(
      userId,
      email,
      content,
      replyTo: replyTo,
      threadId: threadId,
    );
  }

  Future<void> edit(String messageId, String content) {
    return _apiService.editMessage(messageId, content);
  }
}
