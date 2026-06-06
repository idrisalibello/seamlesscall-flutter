import 'package:seamlesscall/features/customer/domain/chat_message.dart';

class AdminChatConversation {
  final int customerId;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String lastMessage;
  final String lastSender;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const AdminChatConversation({
    required this.customerId,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    required this.lastMessage,
    required this.lastSender,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory AdminChatConversation.fromJson(Map<String, dynamic> json) {
    return AdminChatConversation(
      customerId: _toInt(json['customer_id']) ?? 0,
      customerName: _clean(json['customer_name']) ?? 'Customer',
      customerEmail: _clean(json['customer_email']),
      customerPhone: _clean(json['customer_phone']),
      lastMessage: _clean(json['last_message']) ?? 'No message',
      lastSender: _clean(json['last_sender']) ?? 'customer',
      lastMessageAt: _parseDate(json['last_message_at']),
      unreadCount: _toInt(json['unread_count']) ?? 0,
    );
  }

  AdminChatConversation copyWith({int? unreadCount}) {
    return AdminChatConversation(
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      lastMessage: lastMessage,
      lastSender: lastSender,
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  static String? _clean(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

class AdminChatThread {
  final AdminChatConversation conversation;
  final List<ChatMessage> messages;

  const AdminChatThread({
    required this.conversation,
    required this.messages,
  });
}
