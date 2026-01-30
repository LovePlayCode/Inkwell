import 'package:flutter/material.dart';

/// 应用常量定义
class AppConstants {
  // 圆角大小
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // 间距
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // 工具栏高度
  static const double toolBarHeight = 56.0;

  // 搜索栏
  static const double searchBarWidth = 320.0;
  static const double searchBarHeight = 44.0;

  // 内容区最大宽度
  static const double contentMaxWidth = 800.0;

  // 大纲面板宽度
  static const double outlineWidthMin = 180.0;
  static const double outlineWidthDefault = 240.0;
  static const double outlineWidthMax = 360.0;
  static const double outlineCollapsedWidth = 48.0;

  // 响应式断点
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;

  // 动画时长
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 200);
  static const Duration animationSlow = Duration(milliseconds: 300);

  // 搜索防抖延迟
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);
}

/// 响应式布局工具
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppConstants.breakpointMobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.breakpointMobile &&
        width < AppConstants.breakpointDesktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConstants.breakpointDesktop;

  static double getOutlineWidth(BuildContext context) {
    if (isMobile(context)) {
      return 0;
    }
    if (isTablet(context)) {
      return AppConstants.outlineWidthMin;
    }
    return AppConstants.outlineWidthDefault;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppConstants.breakpointDesktop) {
          return desktop;
        }
        if (constraints.maxWidth >= AppConstants.breakpointMobile) {
          return tablet ?? desktop;
        }
        return mobile;
      },
    );
  }
}
