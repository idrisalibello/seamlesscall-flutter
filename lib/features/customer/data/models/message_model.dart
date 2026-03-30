class Message {
  final int senderId;
  final String message;
  final DateTime createdAt;

  Message({
    required this.senderId,
    required this.message,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['sender_id'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}