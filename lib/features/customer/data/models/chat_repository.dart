import 'dart:convert';
import 'package:http/http.dart' as http;
import 'message_model.dart';

class ChatRepository {
  final String baseUrl;
  final String token;

  ChatRepository({required this.baseUrl, required this.token});

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<Message>> fetchMessages(int conversationId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/chat/$conversationId'),
      headers: headers,
    );

    final data = jsonDecode(res.body);
    return data.map<Message>((e) => Message.fromJson(e)).toList();
  }

  Future<void> sendMessage(int conversationId, String message) async {
    await http.post(
      Uri.parse('$baseUrl/chat/send'),
      headers: headers,
      body: jsonEncode({
        'conversation_id': conversationId,
        'message': message,
      }),
    );
  }

  Future<int> startSupportChat() async {
    final res = await http.post(
      Uri.parse('$baseUrl/chat/support/start'),
      headers: headers,
    );

    final data = jsonDecode(res.body);
    return data['conversation_id'];
  }
}