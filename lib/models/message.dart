class Message {
  final String messageId;
  final String chatId;
  final String userId;
  final String? imageUrl;
  final String? email;
  final String content;
  final String type;
  final int timestamp;
  final int? editedAt;
  final String? replyTo; // messageId of the message being replied to
  final String? threadId; // top-level thread messageId
  final bool isMe;

  Message? replyMessage; // optional full replied message
  int replyCount; // number of replies in a thread (client-calculated)
  List<Message>? replies; // optional list of replies for a thread

  /// Returns true if the message has been edited
  bool get isEdited => editedAt != null;

  /// Getter to allow using message.text instead of message.content
  String get text => content;

  Message({
    required this.messageId,
    required this.chatId,
    required this.userId,
    this.email,
    this.imageUrl,
    required this.content,
    required this.type,
    required this.timestamp,
    this.editedAt,
    this.replyTo,
    this.threadId,
    required this.isMe,
    this.replyMessage,
    this.replyCount = 0,
    this.replies,
  });

  /// Create a Message from JSON returned by API
  factory Message.fromJson(Map<String, dynamic> json, String currentUserId) {
    return Message(
      messageId: json['messageId'] ?? '',
      chatId: json['chatId'] ?? '',
      userId: json['userId'] ?? '',
      email: json['email'],
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      timestamp: json['timestamp'] ?? 0,
      editedAt: json['editedAt'],
      replyTo: json['replyTo'],
      threadId: json['threadId'],
      isMe: json['userId'] == currentUserId,
      replyMessage: null,
      replyCount: json['replyCount'] ?? 0,
      replies: (json['replies'] as List<dynamic>?)
          ?.map(
            (r) => Message.fromJson(r as Map<String, dynamic>, currentUserId),
          )
          .toList(),
    );
  }

  /// Empty message (used for safe defaults)
  factory Message.empty() {
    return Message(
      messageId: '',
      chatId: '',
      userId: '',
      email: '',
      content: '',
      type: 'text',
      timestamp: 0,
      isMe: false,
      replyCount: 0,
      replies: [],
    );
  }

  /// Create a copy with updated content, replies, etc.
  Message copyWith({
    String? content,
    int? editedAt,
    Message? replyMessage,
    int? replyCount,
    List<Message>? replies,
  }) {
    return Message(
      messageId: messageId,
      chatId: chatId,
      userId: userId,
      email: email,
      content: content ?? this.content,
      type: type,
      timestamp: timestamp,
      editedAt: editedAt ?? this.editedAt,
      replyTo: replyTo,
      threadId: threadId,
      isMe: isMe,
      replyMessage: replyMessage ?? this.replyMessage,
      replyCount: replyCount ?? this.replyCount,
      replies: replies ?? this.replies,
    );
  }
}
