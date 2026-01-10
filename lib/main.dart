import 'package:flutter/material.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'common/constants/theme.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const SeamlessCallApp(),
    ),
  );
}

class SeamlessCallApp extends StatelessWidget {
  const SeamlessCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeamlessCall',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
