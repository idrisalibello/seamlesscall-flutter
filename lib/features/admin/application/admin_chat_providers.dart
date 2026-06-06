import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/admin/data/admin_chat_models.dart';
import 'package:seamlesscall/features/admin/data/admin_chat_repository.dart';
import 'package:seamlesscall/features/customer/domain/chat_message.dart';
import 'package:uuid/uuid.dart';

final adminChatRepositoryProvider = Provider<AdminChatRepository>((ref) {
  return AdminChatRepository();
});

class AdminChatState {
  final List<AdminChatConversation> conversations;
  final int? selectedCustomerId;
  final List<ChatMessage> messages;
  final bool isLoadingConversations;
  final bool isLoadingMessages;
  final bool isSending;
  final String? error;

  const AdminChatState({
    this.conversations = const [],
    this.selectedCustomerId,
    this.messages = const [],
    this.isLoadingConversations = false,
    this.isLoadingMessages = false,
    this.isSending = false,
    this.error,
  });

  AdminChatConversation? get selectedConversation {
    for (final conversation in conversations) {
      if (conversation.customerId == selectedCustomerId) {
        return conversation;
      }
    }
    return null;
  }

  AdminChatState copyWith({
    List<AdminChatConversation>? conversations,
    int? selectedCustomerId,
    bool clearSelection = false,
    List<ChatMessage>? messages,
    bool? isLoadingConversations,
    bool? isLoadingMessages,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) {
    return AdminChatState(
      conversations: conversations ?? this.conversations,
      selectedCustomerId:
          clearSelection ? null : (selectedCustomerId ?? this.selectedCustomerId),
      messages: messages ?? this.messages,
      isLoadingConversations:
          isLoadingConversations ?? this.isLoadingConversations,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AdminChatNotifier extends StateNotifier<AdminChatState> {
  final AdminChatRepository _repository;
  static const _uuid = Uuid();

  AdminChatNotifier(this._repository) : super(const AdminChatState());

  Future<void> loadConversations() async {
    state = state.copyWith(isLoadingConversations: true, clearError: true);
    try {
      final conversations = await _repository.getConversations();
      state = state.copyWith(
        conversations: conversations,
        isLoadingConversations: false,
        clearSelection: conversations.isEmpty,
      );

      if (state.selectedCustomerId == null && conversations.isNotEmpty) {
        await selectConversation(conversations.first.customerId);
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingConversations: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> selectConversation(int customerId) async {
    state = state.copyWith(
      selectedCustomerId: customerId,
      messages: const [],
      isLoadingMessages: true,
      clearError: true,
    );

    try {
      final messages = await _repository.getMessages(customerId);
      final conversations = state.conversations.map((conversation) {
        if (conversation.customerId == customerId) {
          return conversation.copyWith(unreadCount: 0);
        }
        return conversation;
      }).toList();

      state = state.copyWith(
        conversations: conversations,
        messages: messages,
        isLoadingMessages: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMessages: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> sendMessage(String body) async {
    final customerId = state.selectedCustomerId;
    final text = body.trim();
    if (customerId == null || text.isEmpty) return;

    final localId = _uuid.v4();
    final optimistic = ChatMessage(
      localId: localId,
      customerId: customerId,
      senderRole: ChatSenderRole.agent,
      body: text,
      createdAt: DateTime.now(),
      status: ChatMessageStatus.sending,
    );

    state = state.copyWith(
      messages: [...state.messages, optimistic],
      isSending: true,
      clearError: true,
    );

    try {
      final confirmed = await _repository.sendMessage(customerId, text);
      state = state.copyWith(
        messages: state.messages.map((message) {
          if (message.localId == localId) {
            return confirmed.copyWith(status: ChatMessageStatus.sent);
          }
          return message;
        }).toList(),
        isSending: false,
      );
      await loadConversations();
      state = state.copyWith(selectedCustomerId: customerId);
    } catch (e) {
      state = state.copyWith(
        messages: state.messages.map((message) {
          if (message.localId == localId) {
            return message.copyWith(status: ChatMessageStatus.failed);
          }
          return message;
        }).toList(),
        isSending: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final adminChatProvider =
    StateNotifierProvider<AdminChatNotifier, AdminChatState>((ref) {
  final repository = ref.watch(adminChatRepositoryProvider);
  return AdminChatNotifier(repository);
});
