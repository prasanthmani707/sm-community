import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl =
      'https://qp52pkedx9.execute-api.ap-southeast-1.amazonaws.com/messagen';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Fetch all messages
  Future<List<Message>> fetchMessages(String currentUserId) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) =>
                Message.fromJson(json as Map<String, dynamic>, currentUserId))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch messages: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      if (kIsWeb) {
        throw Exception(
            'Failed to fetch messages from web. Check CORS settings on API Gateway.');
      }
      rethrow;
    }
  }

  /// Send a new message
  Future<void> sendMessage(
    String userId,
    String email,
    String content, {
    String? replyTo,
    String? threadId,
  }) async {
    final payload = {
      "userId": userId,
      "email": email,
      "content": content,
      "type": "text",
      "replyTo": replyTo,
      "threadId": threadId,
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  /// Edit a message
  Future<void> editMessage(String messageId, String newContent) async {
    final payload = {
      "messageId": messageId,
      "content": newContent,
    };

    try {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: _headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to edit message: ${response.body}');
      }
    } catch (e) {
      print('Error editing message: $e');
      rethrow;
    }
  }

  /// Fetch thread messages
  Future<List<Message>> fetchThreadMessages(
      String threadId, String currentUserId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?threadId=$threadId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) =>
                Message.fromJson(json as Map<String, dynamic>, currentUserId))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch thread messages: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching thread messages: $e');
      if (kIsWeb) {
        throw Exception(
            'Failed to fetch thread messages. Check CORS in API Gateway.');
      }
      rethrow;
    }
  }
}
