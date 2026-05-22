import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/features/customer/presentation/customer_chat_screen.dart';

enum ProfileAction { accountSettings, helpSupport, logout }

class ProfileItem {
  final ProfileAction action;
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isDanger;

  const ProfileItem({
    required this.action,
    required this.icon,
    required this.label,
    required this.subtitle,
    this.isDanger = false,
  });
}

class CustomerProfileScreen extends ConsumerStatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  ConsumerState<CustomerProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends ConsumerState<CustomerProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  static const List<ProfileItem> _items = [
    ProfileItem(
      action: ProfileAction.accountSettings,
      icon: Icons.settings,
      label: 'Account Settings',
      subtitle: 'Manage your profile information',
    ),
    ProfileItem(
      action: ProfileAction.helpSupport,
      icon: Icons.help_outline,
      label: 'Help & Support',
      subtitle: 'Chat with support',
    ),
    ProfileItem(
      action: ProfileAction.logout,
      icon: Icons.logout,
      label: 'Logout',
      subtitle: 'Sign out of this device',
      isDanger: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _displayName(AuthState auth) {
    final userName = auth.user?.name.trim();
    if (userName != null && userName.isNotEmpty) return userName;

    final savedName = auth.name?.trim();
    if (savedName != null && savedName.isNotEmpty) return savedName;

    return 'Customer';
  }

  String _displayEmail(AuthState auth) {
    final email = auth.user?.email.trim();
    if (email != null && email.isNotEmpty) return email;
    return 'No email available';
  }

  Future<void> _handleAction(ProfileItem item) async {
    switch (item.action) {
      case ProfileAction.accountSettings:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const _AccountSettingsScreen(),
          ),
        );
        break;
      case ProfileAction.helpSupport:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatShell()),
        );
        break;
      case ProfileAction.logout:
        await _confirmLogout();
        break;
    }
  }

  Future<void> _confirmLogout() async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Logout',
              style: TextStyle(color: cs.onError),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await ref.read(authProvider.notifier).logout(Navigator.of(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final auth = ref.watch(authProvider);
    final avatarUrl = auth.avatarUrl?.trim();

    return SafeArea(
      child: FadeTransition(
        opacity: _fadeIn,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  _ProfileAvatar(avatarUrl: avatarUrl),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName(auth),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _displayEmail(auth),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _AnimatedProfileItem(
                      item: item,
                      delay: 100 * index,
                      onTap: () => _handleAction(item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;

  const _ProfileAvatar({this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return CircleAvatar(
      radius: 40,
      backgroundColor: cs.primaryContainer,
      backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
      child: hasAvatar
          ? null
          : Icon(
              Icons.person,
              size: 48,
              color: cs.onPrimaryContainer,
            ),
    );
  }
}

class _AnimatedProfileItem extends StatefulWidget {
  final ProfileItem item;
  final int delay;
  final VoidCallback onTap;

  const _AnimatedProfileItem({
    required this.item,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_AnimatedProfileItem> createState() => _AnimatedProfileItemState();
}

class _AnimatedProfileItemState extends State<_AnimatedProfileItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = widget.item.isDanger ? cs.error : cs.primary;

    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: Card(
          color: cs.surfaceContainerHighest,
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          shadowColor: cs.shadow.withOpacity(0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            onTap: widget.onTap,
            leading: Icon(widget.item.icon, color: color),
            title: Text(
              widget.item.label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: widget.item.isDanger ? cs.error : cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              widget.item.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: cs.onSurfaceVariant,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountSettingsScreen extends ConsumerWidget {
  const _AccountSettingsScreen();

  String _displayName(AuthState auth) {
    final userName = auth.user?.name.trim();
    if (userName != null && userName.isNotEmpty) return userName;

    final savedName = auth.name?.trim();
    if (savedName != null && savedName.isNotEmpty) return savedName;

    return 'Customer';
  }

  String _displayEmail(AuthState auth) {
    final email = auth.user?.email.trim();
    if (email != null && email.isNotEmpty) return email;
    return 'No email available';
  }

  String _displayPhone(AuthState auth) {
    final phone = auth.user?.phone.trim();
    if (phone != null && phone.isNotEmpty) return phone;
    return 'Not provided';
  }

  Future<void> _openNameEditor(BuildContext context, WidgetRef ref) async {
    final currentAuth = ref.read(authProvider);
    final newName = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => _ChangeNameScreen(initialName: _displayName(currentAuth)),
      ),
    );

    if (newName == null || newName.trim().isEmpty) return;

    final cleanName = newName.trim();
    final notifier = ref.read(authProvider.notifier);
    final latestAuth = ref.read(authProvider);
    final user = latestAuth.user;

    if (user != null) {
      notifier.setUser(user.copyWith(name: cleanName));
    }
    notifier.saveProfile(name: cleanName, avatarUrl: latestAuth.avatarUrl);
  }

  void _openGuardedFlow(BuildContext context, _GuardedProfileFlow flow) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _GuardedProfileFlowScreen(flow: flow),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final auth = ref.watch(authProvider);
    final name = _displayName(auth);
    final email = _displayEmail(auth);
    final phone = _displayPhone(auth);

    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Profile information',
            style: theme.textTheme.titleLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _ProfileInfoTile(
            icon: Icons.person_outline,
            label: 'Name',
            value: name,
            actionLabel: 'Edit',
            onTap: () => _openNameEditor(context, ref),
          ),
          _ProfileInfoTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: email,
            readOnly: true,
          ),
          _ProfileInfoTile(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: phone,
            readOnly: true,
          ),
          const SizedBox(height: 8),
          _SensitiveAccountNotice(
            text:
                'Email and phone changes can affect login access, customer records, and verification. They should be requested carefully and confirmed before they are applied.',
          ),
          const SizedBox(height: 16),
          _ProfileActionButton(
            icon: Icons.mark_email_unread_outlined,
            label: 'Request email change',
            subtitle: 'Requires verification before the email is updated',
            onTap: () => _openGuardedFlow(
              context,
              _GuardedProfileFlow.email,
            ),
          ),
          _ProfileActionButton(
            icon: Icons.phone_iphone_outlined,
            label: 'Request phone change',
            subtitle: 'Requires verification before the phone is updated',
            onTap: () => _openGuardedFlow(
              context,
              _GuardedProfileFlow.phone,
            ),
          ),
          _ProfileActionButton(
            icon: Icons.lock_reset_outlined,
            label: 'Change password',
            subtitle: 'Use a guarded password reset flow',
            onTap: () => _openGuardedFlow(
              context,
              _GuardedProfileFlow.password,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? actionLabel;
  final bool readOnly;
  final VoidCallback? onTap;

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.actionLabel,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      color: cs.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: cs.primary),
        title: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: actionLabel != null
            ? Text(
                actionLabel!,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              )
            : readOnly
                ? Icon(
                    Icons.lock_outline,
                    color: cs.onSurfaceVariant,
                    size: 18,
                  )
                : null,
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      color: cs.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: cs.primary),
        title: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: cs.onSurfaceVariant,
          size: 18,
        ),
      ),
    );
  }
}

class _SensitiveAccountNotice extends StatelessWidget {
  final String text;

  const _SensitiveAccountNotice({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: cs.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeNameScreen extends StatefulWidget {
  final String initialName;

  const _ChangeNameScreen({required this.initialName});

  @override
  State<_ChangeNameScreen> createState() => _ChangeNameScreenState();
}

class _ChangeNameScreenState extends State<_ChangeNameScreen> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Name')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Change name',
              style: theme.textTheme.titleLarge?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final cleanValue = value?.trim() ?? '';
                if (cleanValue.isEmpty) return 'Enter your name';
                if (cleanValue.length < 2) return 'Name is too short';
                return null;
              },
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              child: const Text('Save name'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _GuardedProfileFlow { email, phone, password }

class _GuardedProfileFlowScreen extends StatelessWidget {
  final _GuardedProfileFlow flow;

  const _GuardedProfileFlowScreen({required this.flow});

  String get _title {
    switch (flow) {
      case _GuardedProfileFlow.email:
        return 'Request Email Change';
      case _GuardedProfileFlow.phone:
        return 'Request Phone Change';
      case _GuardedProfileFlow.password:
        return 'Change Password';
    }
  }

  IconData get _icon {
    switch (flow) {
      case _GuardedProfileFlow.email:
        return Icons.mark_email_unread_outlined;
      case _GuardedProfileFlow.phone:
        return Icons.phone_iphone_outlined;
      case _GuardedProfileFlow.password:
        return Icons.lock_reset_outlined;
    }
  }

  String get _body {
    switch (flow) {
      case _GuardedProfileFlow.email:
        return 'Changing your email can affect login access, customer records, order notifications, and verification. A request flow should confirm the new email before applying the change.';
      case _GuardedProfileFlow.phone:
        return 'Changing your phone can affect login access, customer records, technician contact, and verification. A request flow should confirm the new phone number before applying the change.';
      case _GuardedProfileFlow.password:
        return 'Password changes should use a guarded flow with identity confirmation before the new password is accepted.';
    }
  }

  String get _prompt {
    switch (flow) {
      case _GuardedProfileFlow.email:
        return 'Email change request placeholder';
      case _GuardedProfileFlow.phone:
        return 'Phone change request placeholder';
      case _GuardedProfileFlow.password:
        return 'Secure password flow placeholder';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(_icon, color: cs.primary, size: 48),
          const SizedBox(height: 18),
          Text(
            _title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _SensitiveAccountNotice(text: _body),
          const SizedBox(height: 20),
          Card(
            color: cs.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _prompt,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
