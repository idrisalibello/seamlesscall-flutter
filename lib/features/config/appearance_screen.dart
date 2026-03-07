import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/common/constants/theme.dart';
import 'package:seamlesscall/core/theme/theme_providers.dart';
import '../../common/widgets/main_layout.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final controller = ref.read(themeSettingsProvider.notifier);
    final theme = Theme.of(context);

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              'Appearance',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose theme mode and brand style.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Theme mode', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.system,
                      groupValue: settings.mode,
                      title: const Text('System'),
                      subtitle: const Text('Follow device theme'),
                      onChanged: (v) {
                        if (v != null) controller.setThemeMode(v);
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.dark,
                      groupValue: settings.mode,
                      title: const Text('Dark'),
                      subtitle: const Text('Best for your current brand look'),
                      onChanged: (v) {
                        if (v != null) controller.setThemeMode(v);
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.light,
                      groupValue: settings.mode,
                      title: const Text('Light'),
                      subtitle: const Text('Clean light workspace'),
                      onChanged: (v) {
                        if (v != null) controller.setThemeMode(v);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Theme style', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: AppThemeCatalog.all.map((preset) {
                        final selected = settings.preset.id == preset.id;

                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => controller.setPreset(preset),
                          child: Container(
                            width: 240,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: preset.backgroundGradient,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.14),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        preset.label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    if (selected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: preset.accentGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Preview',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}