// lib/features/customer/domain/chat_message.dart

enum ChatSenderRole { customer, agent }

enum ChatMessageType { text, image, file }

enum ChatMessageStatus {
  /// Optimistic — inserted locally, not yet confirmed by server
  sending,
  /// Server confirmed the insert
  sent,
  /// Server confirmed AND the other party has received it
  delivered,
  /// The other party has opened/read it
  read,
  /// Server returned an error
  failed,
}

class ChatMessage {
  final String localId;      // UUID generated on device for optimistic inserts
  final int? serverId;       // id from backend once confirmed
  final int customerId;
  final ChatSenderRole senderRole;
  final int? senderId;       // null when senderRole == customer
  final String? senderName;  // joined from users table (agent name)
  final String? body;
  final ChatMessageType messageType;
  final String? attachmentUrl;   // remote URL once uploaded
  final String? attachmentName;
  final String? localPath;       // device path before upload completes
  final bool isRead;
  final DateTime createdAt;
  final ChatMessageStatus status;

  const ChatMessage({
    required this.localId,
    this.serverId,
    required this.customerId,
    required this.senderRole,
    this.senderId,
    this.senderName,
    this.body,
    this.messageType = ChatMessageType.text,
    this.attachmentUrl,
    this.attachmentName,
    this.localPath,
    this.isRead = false,
    required this.createdAt,
    this.status = ChatMessageStatus.sent,
  });

  bool get isMe => senderRole == ChatSenderRole.customer;

  String get timeLabel {
    final h = createdAt.hour.toString().padLeft(2, '0');
    final m = createdAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  ChatMessage copyWith({
    String? localId,
    int? serverId,
    int? customerId,
    ChatSenderRole? senderRole,
    int? senderId,
    String? senderName,
    String? body,
    ChatMessageType? messageType,
    String? attachmentUrl,
    String? attachmentName,
    String? localPath,
    bool? isRead,
    DateTime? createdAt,
    ChatMessageStatus? status,
  }) {
    return ChatMessage(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      customerId: customerId ?? this.customerId,
      senderRole: senderRole ?? this.senderRole,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      body: body ?? this.body,
      messageType: messageType ?? this.messageType,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      localPath: localPath ?? this.localPath,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  /// Parse a single JSON object from GET /api/v1/customer/chat/messages
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      localId: 'server-${json['id']}',
      serverId: _toInt(json['id']),
      customerId: _toInt(json['customer_id']) ?? 0,
      senderRole: json['sender_role'] == 'agent'
          ? ChatSenderRole.agent
          : ChatSenderRole.customer,
      senderId: _toIntNullable(json['sender_id']),
      senderName: json['sender_name']?.toString(),
      body: json['body']?.toString(),
      messageType: _parseType(json['message_type']),
      attachmentUrl: json['attachment_url']?.toString(),
      attachmentName: json['attachment_name']?.toString(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: _parseDate(json['created_at']),
      status: ChatMessageStatus.delivered,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static int? _toIntNullable(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  static ChatMessageType _parseType(dynamic v) {
    switch (v?.toString()) {
      case 'image':
        return ChatMessageType.image;
      case 'file':
        return ChatMessageType.file;
      default:
        return ChatMessageType.text;
    }
  }
}