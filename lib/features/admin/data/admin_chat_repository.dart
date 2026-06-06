import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';
import 'package:seamlesscall/features/admin/data/admin_chat_models.dart';
import 'package:seamlesscall/features/customer/domain/chat_message.dart';

class AdminChatRepository {
  final Dio _dio = DioClient().dio;

  Future<List<AdminChatConversation>> getConversations() async {
    try {
      final response = await _dio.get('/api/v1/admin/chat/conversations');
      final body = response.data;
      if (body is! Map<String, dynamic>) return const [];

      final data = body['data'];
      if (data is! List) return const [];

      return data
          .map((item) => AdminChatConversation.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(growable: false);
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e, 'Could not load chat inbox.'));
    }
  }

  Future<List<ChatMessage>> getMessages(int customerId) async {
    try {
      final response = await _dio.get(
        '/api/v1/admin/chat/conversations/$customerId/messages',
        queryParameters: {'limit': 80, 'offset': 0},
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) return const [];

      final data = body['data'];
      if (data is! List) return const [];

      return data
          .map((item) => ChatMessage.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e, 'Could not load messages.'));
    }
  }

  Future<ChatMessage> sendMessage(int customerId, String body) async {
    try {
      final response = await _dio.post(
        '/api/v1/admin/chat/conversations/$customerId/messages',
        data: {'body': body},
      );
      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Unexpected response from chat send.');
      }

      return ChatMessage.fromJson(
        Map<String, dynamic>.from(responseBody['data']),
      );
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e, 'Could not send message.'));
    }
  }

  String _messageFromDio(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final messages = data['messages'];
      if (messages is String && messages.isNotEmpty) return messages;
      if (messages is Map && messages.isNotEmpty) {
        return messages.values.first.toString();
      }
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return e.message ?? fallback;
  }
}
