import 'dart:io';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/features/customer/application/chat_providers.dart';
import 'package:seamlesscall/features/customer/domain/chat_message.dart';

class ChatShell extends ConsumerStatefulWidget {
  const ChatShell({super.key});

  @override
  ConsumerState<ChatShell> createState() => _ChatShellState();
}

class _ChatShellState extends ConsumerState<ChatShell> {
  final _textCtrl     = TextEditingController();
  final _scrollCtrl   = ScrollController();
  final _focusNode    = FocusNode();

  bool _showScrollDown = false;
  bool _isTyping       = false;

  @override
  void initState() {
    super.initState();

    // Load real messages on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).loadMessages();
    });

    _scrollCtrl.addListener(() {
      if (!_scrollCtrl.hasClients) return;
      final atBottom =
          _scrollCtrl.offset >= _scrollCtrl.position.maxScrollExtent - 80;
      if (_showScrollDown == atBottom) {
        setState(() => _showScrollDown = !atBottom);
      }
    });

    _textCtrl.addListener(() {
      final hasText = _textCtrl.text.trim().isNotEmpty;
      if (_isTyping != hasText) setState(() => _isTyping = hasText);
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Scroll ─────────────────────────────────────────────────────────────────

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  // ── Send text ──────────────────────────────────────────────────────────────

  void _send() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(authProvider).user;
    if (user == null) return;

    _textCtrl.clear();
    ref.read(chatProvider.notifier).sendMessage(text, user.id!);
    _scrollToBottom();
  }

  // ── Pick & upload attachment ───────────────────────────────────────────────

  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) return;

      final user = ref.read(authProvider).user;
      if (user == null) return;

      final isImage = file.extension != null &&
          ['jpg', 'jpeg', 'png', 'webp', 'gif']
              .contains(file.extension!.toLowerCase());
      final msgType = isImage ? ChatMessageType.image : ChatMessageType.file;

      await ref.read(chatProvider.notifier).sendAttachment(
            filePath: file.path!,
            fileName: file.name,
            customerId: user.id!,
            messageType: msgType,
          );
      _scrollToBottom();
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file picker: ${e.message}')),
      );
    }
  }

  // ── Date separator ─────────────────────────────────────────────────────────

  bool _showDateSeparator(List<ChatMessage> msgs, int index) {
    if (index == 0) return true;
    final prev = msgs[index - 1].createdAt;
    final curr = msgs[index].createdAt;
    return prev.year != curr.year ||
        prev.month != curr.month ||
        prev.day != curr.day;
  }

  String _dateLabel(DateTime dt) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d     = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final cs       = theme.colorScheme;
    final chatState = ref.watch(chatProvider);
    final messages  = chatState.messages;

    // Auto-scroll when a new message arrives
    ref.listen<ChatState>(chatProvider, (prev, next) {
      if ((prev?.messages.length ?? 0) < next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: cs.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: _ChatTopBar(onBack: () => Navigator.pop(context)),
            ),

            const Divider(height: 1, thickness: 0.5),

            // ── Error banner ─────────────────────────────────────────────────
            if (chatState.error != null)
              _ErrorBanner(
                message: chatState.error!,
                onDismiss: () => ref.read(chatProvider.notifier).clearError(),
              ),

            // ── Message list ─────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  if (chatState.isLoading && messages.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (messages.isEmpty)
                    const _ChatEmptyState()
                  else
                    ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      itemCount: messages.length,
                      itemBuilder: (context, i) {
                        final msg = messages[i];
                        return Column(
                          children: [
                            if (_showDateSeparator(messages, i))
                              _DateSeparator(
                                  label: _dateLabel(msg.createdAt)),
                            _AnimatedMessageIn(
                              animate: DateTime.now()
                                      .difference(msg.createdAt)
                                      .inSeconds < 2,
                              child: _ChatBubble(
                                message: msg,
                                onRetry: msg.status == ChatMessageStatus.failed
                                    ? () {
                                        final user =
                                            ref.read(authProvider).user;
                                        if (user != null) {
                                          ref
                                              .read(chatProvider.notifier)
                                              .retryFailed(msg, user.id!);
                                        }
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  // Scroll-to-bottom button
                  if (_showScrollDown)
                    Positioned(
                      right: 16,
                      bottom: 8,
                      child: _ScrollDownButton(onTap: _scrollToBottom),
                    ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 0.5),

            // ── Composer ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: _Composer(
                controller: _textCtrl,
                focusNode: _focusNode,
                isTyping: _isTyping,
                isSending: chatState.isSending,
                onSend: _send,
                onAttach: _pickAttachment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Components ───────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: cs.onErrorContainer, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Could not send message. Tap retry on the failed message.',
              style: TextStyle(color: cs.onErrorContainer, fontSize: 12),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: cs.onErrorContainer, size: 18),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _ChatTopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _ChatTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onBack,
          child: Ink(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
            ),
            child: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(0.80),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.support_agent_rounded,
              color: cs.primary, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Support Chat',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Typically replies in minutes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.60),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(0.75),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.primary.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_rounded, size: 14, color: cs.primary),
              const SizedBox(width: 5),
              Text(
                'Verified',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
              child: Divider(color: cs.outlineVariant.withOpacity(0.5))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.55),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface.withOpacity(0.55),
                    ),
              ),
            ),
          ),
          Expanded(
              child: Divider(color: cs.outlineVariant.withOpacity(0.5))),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRetry;

  const _ChatBubble({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    final isMe  = message.isMe;

    final bubbleColor = isMe
        ? cs.primaryContainer.withOpacity(0.90)
        : cs.surfaceContainerLow;
    final borderColor = isMe
        ? cs.primary.withOpacity(0.18)
        : cs.outlineVariant.withOpacity(0.5);
    final radius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(5),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(5),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: message.status == ChatMessageStatus.failed
                        ? cs.errorContainer
                        : bubbleColor,
                    borderRadius: radius,
                    border: Border.all(
                      color: message.status == ChatMessageStatus.failed
                          ? cs.error.withOpacity(0.3)
                          : borderColor,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: message.messageType == ChatMessageType.text
                      ? Text(
                          message.body ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withOpacity(0.88),
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        )
                      : _AttachmentContent(message: message),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  message.timeLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.48),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _StatusTick(status: message.status),
                ],
                if (isMe &&
                    message.status == ChatMessageStatus.failed &&
                    onRetry != null) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onRetry,
                    child: Text(
                      'Retry',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.error,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentContent extends StatelessWidget {
  final ChatMessage message;
  const _AttachmentContent({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    // Show local file if not yet uploaded, remote URL once confirmed
    final displayPath = message.attachmentUrl ?? message.localPath ?? '';
    final isRemote    = message.attachmentUrl != null;
    final isImage     = message.messageType == ChatMessageType.image;

    if (isImage && displayPath.isNotEmpty) {
      final imageWidget = isRemote
          ? Image.network(
              displayPath,
              width: 200,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _FileTile(name: message.attachmentName ?? 'Image'),
            )
          : Image.file(
              File(displayPath),
              width: 200,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _FileTile(name: message.attachmentName ?? 'Image'),
            );

      return Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageWidget,
          ),
          if (message.status == ChatMessageStatus.sending)
            Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ),
        ],
      );
    }

    return _FileTile(name: message.attachmentName ?? message.body ?? 'File');
  }
}

class _FileTile extends StatelessWidget {
  final String name;
  const _FileTile({required this.name});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.insert_drive_file_rounded, color: cs.primary, size: 22),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withOpacity(0.88),
                ),
          ),
        ),
      ],
    );
  }
}

class _StatusTick extends StatelessWidget {
  final ChatMessageStatus status;
  const _StatusTick({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case ChatMessageStatus.sending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: cs.onSurface.withOpacity(0.40),
          ),
        );
      case ChatMessageStatus.sent:
        return Icon(Icons.check_rounded,
            size: 14, color: cs.onSurface.withOpacity(0.45));
      case ChatMessageStatus.delivered:
        return Icon(Icons.done_all_rounded,
            size: 14, color: cs.onSurface.withOpacity(0.45));
      case ChatMessageStatus.read:
        return Icon(Icons.done_all_rounded, size: 14, color: cs.primary);
      case ChatMessageStatus.failed:
        return Icon(Icons.error_outline_rounded, size: 14, color: cs.error);
    }
  }
}

class _ScrollDownButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ScrollDownButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: cs.surface,
          shape: BoxShape.circle,
          border: Border.all(color: cs.outlineVariant.withOpacity(0.7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: cs.onSurface.withOpacity(0.75),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isTyping;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.isTyping,
    required this.isSending,
    required this.onSend,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: isSending ? null : onAttach,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.attach_file_rounded,
                color: cs.onSurface.withOpacity(isSending ? 0.25 : 0.55),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Type a message…',
                hintStyle: TextStyle(
                  color: cs.onSurface.withOpacity(0.42),
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isTyping && !isSending
                  ? cs.primary
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: (isTyping && !isSending) ? onSend : null,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: isSending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onSurface.withOpacity(0.4),
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: isTyping
                            ? cs.onPrimary
                            : cs.onSurface.withOpacity(0.38),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: cs.outlineVariant.withOpacity(0.6)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.chat_bubble_outline_rounded,
                    color: cs.primary, size: 28),
              ),
              const SizedBox(height: 14),
              Text(
                'No messages yet',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ask about services, pricing, or availability.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.62),
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Animation helper ─────────────────────────────────────────────────────────

class _AnimatedMessageIn extends StatefulWidget {
  final Widget child;
  final bool animate;
  const _AnimatedMessageIn({required this.child, this.animate = true});

  @override
  State<_AnimatedMessageIn> createState() => _AnimatedMessageInState();
}

class _AnimatedMessageInState extends State<_AnimatedMessageIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: widget.animate ? 0 : 1,
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.04),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    if (widget.animate) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// keep the math import satisfied (used indirectly if typing indicator is re-added)
// ignore: unused_import, unnecessary_import
final _mathRef = math.pi;