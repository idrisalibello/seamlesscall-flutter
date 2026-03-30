// lib/features/customer/data/chat_api.dart

import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';
import 'package:seamlesscall/features/customer/domain/chat_message.dart';

class ChatApi {
  final Dio _dio = DioClient().dio;

  // ── GET /api/v1/customer/chat/messages ────────────────────────────────────

  Future<List<ChatMessage>> getMessages({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/customer/chat/messages',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw Exception('Unexpected response shape from chat/messages');
      }

      final data = body['data'];
      if (data is! List) return const [];

      return data
          .map((json) => ChatMessage.fromJson(Map<String, dynamic>.from(json)))
          .toList(growable: false);
    } on DioException {
      rethrow;
    }
  }

  // ── POST /api/v1/customer/chat/messages ───────────────────────────────────

  Future<ChatMessage> sendMessage(String body) async {
    try {
      final response = await _dio.post(
        '/api/v1/customer/chat/messages',
        data: {'body': body},
      );

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Unexpected response shape from chat/messages POST');
      }

      return ChatMessage.fromJson(
        Map<String, dynamic>.from(responseBody['data']),
      );
    } on DioException {
      rethrow;
    }
  }

  // ── POST /api/v1/customer/chat/attachments ────────────────────────────────

  Future<ChatMessage> uploadAttachment(String filePath, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post(
        '/api/v1/customer/chat/attachments',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw Exception('Unexpected response shape from chat/attachments POST');
      }

      return ChatMessage.fromJson(
        Map<String, dynamic>.from(body['data']),
      );
    } on DioException {
      rethrow;
    }
  }

  // ── GET /api/v1/customer/chat/unread-count ────────────────────────────────

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/api/v1/customer/chat/unread-count');

      final body = response.data;
      if (body is! Map<String, dynamic>) return 0;

      final data = body['data'];
      if (data is! Map<String, dynamic>) return 0;

      return (data['unread_count'] as int?) ?? 0;
    } on DioException {
      rethrow;
    }
  }
}