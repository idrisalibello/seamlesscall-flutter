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

  Future<void> _handleAction(ProfileItem item, AuthState auth) async {
    switch (item.action) {
      case ProfileAction.accountSettings:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _AccountSettingsPlaceholder(
              name: _displayName(auth),
              email: _displayEmail(auth),
              phone: auth.user?.phone ?? 'Not provided',
            ),
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
                      onTap: () => _handleAction(item, auth),
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

class _AccountSettingsPlaceholder extends StatelessWidget {
  final String name;
  final String email;
  final String phone;

  const _AccountSettingsPlaceholder({
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
          ),
          _ProfileInfoTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: email,
          ),
          _ProfileInfoTile(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: phone,
          ),
          const SizedBox(height: 12),
          Text(
            'Profile editing will be connected here when account update APIs are ready.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
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

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      color: cs.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
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
      ),
    );
  }
}
