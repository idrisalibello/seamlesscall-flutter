// lib/features/customer/application/chat_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/customer/data/chat_repository.dart';
import 'package:seamlesscall/features/customer/domain/chat_message.dart';
import 'package:uuid/uuid.dart';

// ─── Repository provider ──────────────────────────────────────────────────────

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

// ─── Unread count (home screen badge) ────────────────────────────────────────

final chatUnreadCountProvider = FutureProvider.autoDispose<int>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getUnreadCount();
});

// ─── Chat state ───────────────────────────────────────────────────────────────

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final bool isSending;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.isSending = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isSending,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSending: isSending ?? this.isSending,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  static const _uuid = Uuid();

  ChatNotifier(this._repository) : super(const ChatState());

  // ── Load history ──────────────────────────────────────────────────────────

  Future<void> loadMessages({int limit = 50, int offset = 0}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final messages = await _repository.getMessages(
        limit: limit,
        offset: offset,
      );
      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ── Send text — optimistic insert then confirm ────────────────────────────

  Future<void> sendMessage(String body, int customerId) async {
    if (body.trim().isEmpty) return;

    final localId = _uuid.v4();
    final optimistic = ChatMessage(
      localId: localId,
      customerId: customerId,
      senderRole: ChatSenderRole.customer,
      body: body.trim(),
      createdAt: DateTime.now(),
      status: ChatMessageStatus.sending,
    );

    // 1. Append optimistic message immediately
    state = state.copyWith(
      messages: [...state.messages, optimistic],
      isSending: true,
    );

    try {
      // 2. Call API
      final confirmed = await _repository.sendMessage(body.trim());

      // 3. Replace optimistic with confirmed
      state = state.copyWith(
        messages: state.messages
            .map((m) => m.localId == localId
                ? confirmed.copyWith(status: ChatMessageStatus.sent)
                : m)
            .toList(),
        isSending: false,
      );
    } catch (e) {
      // 4. Mark as failed if API errors
      state = state.copyWith(
        messages: state.messages
            .map((m) => m.localId == localId
                ? m.copyWith(status: ChatMessageStatus.failed)
                : m)
            .toList(),
        isSending: false,
        error: e.toString(),
      );
    }
  }

  // ── Upload attachment — optimistic, then confirm ──────────────────────────

  Future<void> sendAttachment({
    required String filePath,
    required String fileName,
    required int customerId,
    required ChatMessageType messageType,
  }) async {
    final localId = _uuid.v4();
    final optimistic = ChatMessage(
      localId: localId,
      customerId: customerId,
      senderRole: ChatSenderRole.customer,
      messageType: messageType,
      attachmentName: fileName,
      localPath: filePath,
      createdAt: DateTime.now(),
      status: ChatMessageStatus.sending,
    );

    state = state.copyWith(
      messages: [...state.messages, optimistic],
      isSending: true,
    );

    try {
      final confirmed = await _repository.uploadAttachment(filePath, fileName);

      state = state.copyWith(
        messages: state.messages
            .map((m) => m.localId == localId
                ? confirmed.copyWith(status: ChatMessageStatus.sent)
                : m)
            .toList(),
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(
        messages: state.messages
            .map((m) => m.localId == localId
                ? m.copyWith(status: ChatMessageStatus.failed)
                : m)
            .toList(),
        isSending: false,
        error: e.toString(),
      );
    }
  }

  // ── Retry a failed message ────────────────────────────────────────────────

  Future<void> retryFailed(ChatMessage failed, int customerId) async {
    // Remove the failed message then resend
    state = state.copyWith(
      messages: state.messages.where((m) => m.localId != failed.localId).toList(),
    );

    if (failed.messageType == ChatMessageType.text && failed.body != null) {
      await sendMessage(failed.body!, customerId);
    } else if (failed.localPath != null && failed.attachmentName != null) {
      await sendAttachment(
        filePath: failed.localPath!,
        fileName: failed.attachmentName!,
        customerId: customerId,
        messageType: failed.messageType,
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatNotifier(repository);
});