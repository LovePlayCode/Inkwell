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
  static const double outlineWidth = 220.0;

  // 动画时长
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 200);
  static const Duration animationSlow = Duration(milliseconds: 300);

  // 搜索防抖延迟
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);
}
