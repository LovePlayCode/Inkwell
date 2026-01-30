import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/document_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

/// 顶部工具栏
class ToolBar extends StatelessWidget {
  const ToolBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final documentProvider = context.watch<DocumentProvider>();
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);

    return Container(
      height: AppConstants.toolBarHeight,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? AppConstants.spacingSmall
            : AppConstants.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerTheme.color ?? Colors.transparent,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 移动端菜单按钮
          if (isMobile && documentProvider.hasDocument) ...[
            _ToolBarButton(
              icon: Icons.menu_rounded,
              tooltip: '显示大纲',
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
          ],

          // 应用图标和标题
          _AppLogo(isMobile: isMobile),

          const SizedBox(width: AppConstants.spacingMedium),

          // 文件名或应用名
          Expanded(
            child: _FileNameDisplay(
              fileName: documentProvider.fileName,
              isMobile: isMobile,
            ),
          ),

          // 工具按钮组
          _ToolButtonGroup(
            documentProvider: documentProvider,
            themeProvider: themeProvider,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }
}

/// 应用 Logo
class _AppLogo extends StatefulWidget {
  final bool isMobile;

  const _AppLogo({required this.isMobile});

  @override
  State<_AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<_AppLogo>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: EdgeInsets.all(
            widget.isMobile
                ? AppConstants.spacingXSmall + 2
                : AppConstants.spacingSmall,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                _isHovered ? AppTheme.primaryDark : const Color(0xFF5856D6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            Icons.description_outlined,
            color: Colors.white,
            size: widget.isMobile ? 18 : 20,
          ),
        ),
      ),
    );
  }
}

/// 文件名显示
class _FileNameDisplay extends StatelessWidget {
  final String? fileName;
  final bool isMobile;

  const _FileNameDisplay({
    required this.fileName,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = fileName ?? 'MD Reader';
    final hasFile = fileName != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasFile && !isMobile)
          Container(
            margin: const EdgeInsets.only(right: AppConstants.spacingSmall),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingSmall,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
            ),
            child: Text(
              '.md',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        Flexible(
          child: Text(
            hasFile ? displayName.replaceAll('.md', '') : displayName,
            style: theme.appBarTheme.titleTextStyle?.copyWith(
              fontSize: isMobile ? 16 : 18,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// 工具按钮组
class _ToolButtonGroup extends StatelessWidget {
  final DocumentProvider documentProvider;
  final ThemeProvider themeProvider;
  final bool isMobile;

  const _ToolButtonGroup({
    required this.documentProvider,
    required this.themeProvider,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 大纲切换按钮（非移动端）
        if (!isMobile && documentProvider.hasDocument) ...[
          _ToolBarButton(
            icon: documentProvider.isOutlinePanelExpanded
                ? Icons.view_sidebar_outlined
                : Icons.view_sidebar_rounded,
            tooltip: documentProvider.isOutlinePanelExpanded
                ? '收起大纲 (⌘B)'
                : '展开大纲 (⌘B)',
            isActive: documentProvider.isOutlinePanelExpanded,
            onPressed: () => documentProvider.toggleOutlinePanel(),
          ),
          const SizedBox(width: AppConstants.spacingXSmall),
        ],

        // 打开文件按钮
        _ToolBarButton(
          icon: Icons.folder_open_outlined,
          tooltip: '打开文件',
          onPressed: documentProvider.isLoading
              ? null
              : () => documentProvider.openFile(),
        ),

        const SizedBox(width: AppConstants.spacingXSmall),

        // 搜索按钮
        _ToolBarButton(
          icon: Icons.search_rounded,
          tooltip: '搜索 (⌘F)',
          isActive: documentProvider.isSearchVisible,
          onPressed: documentProvider.hasDocument
              ? () => documentProvider.toggleSearch()
              : null,
        ),

        const SizedBox(width: AppConstants.spacingXSmall),

        // 主题切换按钮
        _ThemeToggleButton(
          isDarkMode: themeProvider.isDarkMode,
          onPressed: () => themeProvider.toggleTheme(),
        ),
      ],
    );
  }
}

/// 主题切换按钮
class _ThemeToggleButton extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onPressed;

  const _ThemeToggleButton({
    required this.isDarkMode,
    required this.onPressed,
  });

  @override
  State<_ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<_ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.animationNormal,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isDarkMode) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(_ThemeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDarkMode != oldWidget.isDarkMode) {
      if (widget.isDarkMode) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ToolBarButton(
      icon: widget.isDarkMode
          ? Icons.light_mode_outlined
          : Icons.dark_mode_outlined,
      tooltip: widget.isDarkMode ? '浅色模式' : '深色模式',
      onPressed: widget.onPressed,
      customChild: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return RotationTransition(
            turns: _rotationAnimation,
            child: child,
          );
        },
        child: Icon(
          widget.isDarkMode
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
          size: 22,
        ),
      ),
    );
  }
}

/// 工具栏按钮
class _ToolBarButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isActive;
  final Widget? customChild;

  const _ToolBarButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.isActive = false,
    this.customChild,
  });

  @override
  State<_ToolBarButton> createState() => _ToolBarButtonState();
}

class _ToolBarButtonState extends State<_ToolBarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null;

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: AppConstants.animationFast,
          decoration: BoxDecoration(
            color: widget.isActive
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : _isHovered && isEnabled
                    ? (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingSmall),
                child: widget.customChild ??
                    Icon(
                      widget.icon,
                      size: 22,
                      color: widget.isActive
                          ? theme.colorScheme.primary
                          : isEnabled
                              ? theme.iconTheme.color
                              : theme.iconTheme.color?.withValues(alpha: 0.4),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
