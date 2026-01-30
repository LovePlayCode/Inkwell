import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// 应用主题配置
class AppTheme {
  // 主色调
  static const Color primaryColor = Color(0xFF007AFF);
  static const Color primaryDark = Color(0xFF5856D6);

  // 功能色
  static const Color highlightColor = Color(0xFFFFE066);
  static const Color successColor = Color(0xFF34C759);
  static const Color errorColor = Color(0xFFFF3B30);
  static const Color warningColor = Color(0xFFFF9500);

  /// 浅色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryDark,
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF1D1D1F),
        onPrimary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Color(0xFF1D1D1F),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'PingFang SC',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D1D1F),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'PingFang SC',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D1D1F),
        ),
        headlineMedium: TextStyle(
          fontFamily: 'PingFang SC',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1D1D1F),
        ),
        bodyLarge: TextStyle(
          fontFamily: 'PingFang SC',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF1D1D1F),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'PingFang SC',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF86868B),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF86868B),
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E5EA),
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMedium,
            vertical: AppConstants.spacingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingSmall,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }

  /// 深色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF1C1C1E),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryDark,
        surface: Color(0xFF2C2C2E),
        onSurface: Color(0xFFF5F5F7),
        onPrimary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2C2C2E),
        foregroundColor: Color(0xFFF5F5F7),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'PingFang SC',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF5F5F7),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'PingFang SC',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF5F5F7),
        ),
        headlineMedium: TextStyle(
          fontFamily: 'PingFang SC',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Color(0xFFF5F5F7),
        ),
        bodyLarge: TextStyle(
          fontFamily: 'PingFang SC',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFFF5F5F7),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'PingFang SC',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFA1A1A6),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFA1A1A6),
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3A3A3C),
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMedium,
            vertical: AppConstants.spacingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF3A3A3C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingSmall,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2C2C2E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
