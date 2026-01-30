import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

/// 应用根组件
class MDReaderApp extends StatelessWidget {
  const MDReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'MD Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      themeAnimationDuration: AppConstants.animationNormal,
      themeAnimationCurve: Curves.easeInOut,
      home: const HomeScreen(),
    );
  }
}
