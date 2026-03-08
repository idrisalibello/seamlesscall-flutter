import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:seamlesscall/common/constants/theme.dart';

const _themeModeKey = 'theme_mode';
const _themePresetKey = 'theme_preset';

String _encodeThemeMode(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}

ThemeMode _decodeThemeMode(String? value) {
  switch ((value ?? '').toLowerCase()) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

class ThemeSettingsState {
  final ThemeMode mode;
  final AppThemeSpec preset;
  final bool loaded;

  const ThemeSettingsState({
    required this.mode,
    required this.preset,
    required this.loaded,
  });

  ThemeSettingsState copyWith({
    ThemeMode? mode,
    AppThemeSpec? preset,
    bool? loaded,
  }) {
    return ThemeSettingsState(
      mode: mode ?? this.mode,
      preset: preset ?? this.preset,
      loaded: loaded ?? this.loaded,
    );
  }
}

class ThemeSettingsController extends StateNotifier<ThemeSettingsState> {
  final FlutterSecureStorage _storage;

  ThemeSettingsController({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      super(
        const ThemeSettingsState(
          mode: ThemeMode.dark,
          preset: AppThemeCatalog.darkBlue,
          loaded: false,
        ),
      ) {
    _load();
  }

  Future<void> _load() async {
    final modeRaw = await _storage.read(key: _themeModeKey);
    final presetRaw = await _storage.read(key: _themePresetKey);

    final resolvedMode = (() {
      final decoded = _decodeThemeMode(modeRaw);
      // safe default for existing installs that previously followed system
      if (modeRaw == null || decoded == ThemeMode.system) {
        return ThemeMode.dark;
      }
      return decoded;
    })();

    state = state.copyWith(
      mode: resolvedMode,
      preset: AppThemeCatalog.byId(presetRaw ?? AppThemeCatalog.darkBlue.id),
      loaded: true,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _storage.write(key: _themeModeKey, value: _encodeThemeMode(mode));
  }

  Future<void> setPreset(AppThemeSpec preset) async {
    state = state.copyWith(preset: preset);
    await _storage.write(key: _themePresetKey, value: preset.id);
  }
}

final themeSettingsProvider =
    StateNotifierProvider<ThemeSettingsController, ThemeSettingsState>((ref) {
      return ThemeSettingsController();
    });
