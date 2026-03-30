// lib/features/customer/data/chat_repository.dart

import 'package:seamlesscall/features/customer/data/chat_api.dart';
import 'package:seamlesscall/features/customer/domain/chat_message.dart';

class ChatRepository {
  final ChatApi _api;

  ChatRepository({ChatApi? api}) : _api = api ?? ChatApi();

  /// Load message history for the authenticated customer.
  /// Returns messages in chronological order (oldest first).
  Future<List<ChatMessage>> getMessages({
    int limit = 50,
    int offset = 0,
  }) async {
    return _api.getMessages(limit: limit, offset: offset);
  }

  /// Send a plain text message.
  /// Returns the confirmed [ChatMessage] from the server.
  Future<ChatMessage> sendMessage(String body) async {
    return _api.sendMessage(body);
  }

  /// Upload a file or image attachment.
  /// [filePath] is the local device path.
  /// [fileName] is the display name.
  /// Returns the confirmed [ChatMessage] from the server.
  Future<ChatMessage> uploadAttachment(
    String filePath,
    String fileName,
  ) async {
    return _api.uploadAttachment(filePath, fileName);
  }

  /// Returns the number of unread messages from the agent.
  /// Used for home screen notification badge.
  Future<int> getUnreadCount() async {
    return _api.getUnreadCount();
  }
}