import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/admin/application/admin_chat_providers.dart';
import 'package:seamlesscall/features/admin/data/admin_chat_models.dart';
import 'package:seamlesscall/features/customer/domain/chat_message.dart';

class AdminChatScreen extends ConsumerStatefulWidget {
  const AdminChatScreen({super.key});

  @override
  ConsumerState<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends ConsumerState<AdminChatScreen> {
  final _composerController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showThreadOnMobile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminChatProvider.notifier).loadConversations();
    });
  }

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _selectConversation(int customerId, bool isMobile) async {
    await ref.read(adminChatProvider.notifier).selectConversation(customerId);
    if (mounted && isMobile) {
      setState(() => _showThreadOnMobile = true);
    }
    _scrollToBottom();
  }

  Future<void> _send() async {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;

    _composerController.clear();
    await ref.read(adminChatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminChatProvider);
    final isMobile = MediaQuery.of(context).size.width < 860;

    ref.listen<AdminChatState>(adminChatProvider, (previous, next) {
      if ((previous?.messages.length ?? 0) < next.messages.length) {
        _scrollToBottom();
      }
    });

    if (isMobile) {
      return _AdminChatMobileLayout(
        state: state,
        showThread: _showThreadOnMobile && state.selectedConversation != null,
        composerController: _composerController,
        scrollController: _scrollController,
        onBackToInbox: () => setState(() => _showThreadOnMobile = false),
        onRefresh: () => ref.read(adminChatProvider.notifier).loadConversations(),
        onSelect: (customerId) => _selectConversation(customerId, true),
        onSend: _send,
        onDismissError: () => ref.read(adminChatProvider.notifier).clearError(),
      );
    }

    return _AdminChatDesktopLayout(
      state: state,
      composerController: _composerController,
      scrollController: _scrollController,
      onRefresh: () => ref.read(adminChatProvider.notifier).loadConversations(),
      onSelect: (customerId) => _selectConversation(customerId, false),
      onSend: _send,
      onDismissError: () => ref.read(adminChatProvider.notifier).clearError(),
    );
  }
}

class _AdminChatDesktopLayout extends StatelessWidget {
  final AdminChatState state;
  final TextEditingController composerController;
  final ScrollController scrollController;
  final VoidCallback onRefresh;
  final ValueChanged<int> onSelect;
  final VoidCallback onSend;
  final VoidCallback onDismissError;

  const _AdminChatDesktopLayout({
    required this.state,
    required this.composerController,
    required this.scrollController,
    required this.onRefresh,
    required this.onSelect,
    required this.onSend,
    required this.onDismissError,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 360,
          child: _ConversationInbox(
            state: state,
            onRefresh: onRefresh,
            onSelect: onSelect,
          ),
        ),
        VerticalDivider(width: 1, color: cs.outlineVariant),
        Expanded(
          child: _ChatThread(
            state: state,
            composerController: composerController,
            scrollController: scrollController,
            onSend: onSend,
            onDismissError: onDismissError,
          ),
        ),
      ],
    );
  }
}

class _AdminChatMobileLayout extends StatelessWidget {
  final AdminChatState state;
  final bool showThread;
  final TextEditingController composerController;
  final ScrollController scrollController;
  final VoidCallback onBackToInbox;
  final VoidCallback onRefresh;
  final ValueChanged<int> onSelect;
  final VoidCallback onSend;
  final VoidCallback onDismissError;

  const _AdminChatMobileLayout({
    required this.state,
    required this.showThread,
    required this.composerController,
    required this.scrollController,
    required this.onBackToInbox,
    required this.onRefresh,
    required this.onSelect,
    required this.onSend,
    required this.onDismissError,
  });

  @override
  Widget build(BuildContext context) {
    if (!showThread) {
      return _ConversationInbox(
        state: state,
        onRefresh: onRefresh,
        onSelect: onSelect,
      );
    }

    return _ChatThread(
      state: state,
      composerController: composerController,
      scrollController: scrollController,
      onBack: onBackToInbox,
      onSend: onSend,
      onDismissError: onDismissError,
    );
  }
}

class _ConversationInbox extends StatelessWidget {
  final AdminChatState state;
  final VoidCallback onRefresh;
  final ValueChanged<int> onSelect;

  const _ConversationInbox({
    required this.state,
    required this.onRefresh,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 14, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Support Chat',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: state.isLoadingConversations ? null : onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
        if (state.isLoadingConversations && state.conversations.isEmpty)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (state.conversations.isEmpty)
          const Expanded(
            child: Center(
              child: Text('No customer conversations yet.'),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => onRefresh(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                itemCount: state.conversations.length,
                itemBuilder: (context, index) {
                  final conversation = state.conversations[index];
                  return _ConversationTile(
                    conversation: conversation,
                    selected:
                        state.selectedCustomerId == conversation.customerId,
                    onTap: () => onSelect(conversation.customerId),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final AdminChatConversation conversation;
  final bool selected;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: selected ? 2 : 0,
      color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: selected ? cs.primary : cs.primaryContainer,
          child: Text(
            conversation.customerName.isEmpty
                ? 'C'
                : conversation.customerName[0].toUpperCase(),
            style: TextStyle(
              color: selected ? cs.onPrimary : cs.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: selected ? cs.onPrimaryContainer : cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (conversation.unreadCount > 0)
              Badge(label: Text(conversation.unreadCount.toString())),
          ],
        ),
        subtitle: Text(
          conversation.lastMessage,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ChatThread extends StatelessWidget {
  final AdminChatState state;
  final TextEditingController composerController;
  final ScrollController scrollController;
  final VoidCallback? onBack;
  final VoidCallback onSend;
  final VoidCallback onDismissError;

  const _ChatThread({
    required this.state,
    required this.composerController,
    required this.scrollController,
    this.onBack,
    required this.onSend,
    required this.onDismissError,
  });

  @override
  Widget build(BuildContext context) {
    final conversation = state.selectedConversation;

    if (conversation == null) {
      return const Center(child: Text('Select a conversation to start.'));
    }

    return Column(
      children: [
        _ThreadHeader(conversation: conversation, onBack: onBack),
        if (state.error != null)
          _ErrorBanner(message: state.error!, onDismiss: onDismissError),
        Expanded(
          child: state.isLoadingMessages
              ? const Center(child: CircularProgressIndicator())
              : state.messages.isEmpty
                  ? const Center(child: Text('No messages in this thread.'))
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(18),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        return _AdminMessageBubble(
                          message: state.messages[index],
                        );
                      },
                    ),
        ),
        _ReplyComposer(
          controller: composerController,
          isSending: state.isSending,
          onSend: onSend,
        ),
      ],
    );
  }
}

class _ThreadHeader extends StatelessWidget {
  final AdminChatConversation conversation;
  final VoidCallback? onBack;

  const _ThreadHeader({required this.conversation, this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 4),
          ],
          CircleAvatar(
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.person_rounded, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.customerName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    conversation.customerEmail,
                    conversation.customerPhone,
                  ].whereType<String>().join('  |  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _AdminMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isAdmin = message.senderRole == ChatSenderRole.agent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment:
            isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.56,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              decoration: BoxDecoration(
                color: isAdmin ? cs.primaryContainer : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.body ??
                        message.attachmentName ??
                        (message.messageType == ChatMessageType.image
                            ? 'Image'
                            : 'Attachment'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isAdmin ? cs.onPrimaryContainer : cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.timeLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: (isAdmin ? cs.onPrimaryContainer : cs.onSurface)
                          .withOpacity(0.58),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _ReplyComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              enabled: !isSending,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: const InputDecoration(
                hintText: 'Reply to customer',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: isSending ? null : onSend,
            icon: isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.errorContainer,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: cs.onErrorContainer),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: Icon(Icons.close_rounded, color: cs.onErrorContainer),
          ),
        ],
      ),
    );
  }
}
