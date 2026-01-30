import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/document_provider.dart';
import '../utils/constants.dart';

/// 顶部工具栏
class ToolBar extends StatelessWidget {
  const ToolBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final documentProvider = context.watch<DocumentProvider>();

    return Container(
      height: AppConstants.toolBarHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerTheme.color ?? Colors.transparent,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 应用图标和标题
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSmall),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          
          // 文件名或应用名
          Expanded(
            child: Text(
              documentProvider.fileName ?? 'MD Reader',
              style: theme.appBarTheme.titleTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // 打开文件按钮
          _ToolBarButton(
            icon: Icons.folder_open_outlined,
            tooltip: '打开文件',
            onPressed: documentProvider.isLoading
                ? null
                : () => documentProvider.openFile(),
          ),
          
          const SizedBox(width: AppConstants.spacingSmall),
          
          // 搜索按钮
          _ToolBarButton(
            icon: Icons.search,
            tooltip: '搜索 (⌘F)',
            isActive: documentProvider.isSearchVisible,
            onPressed: documentProvider.hasDocument
                ? () => documentProvider.toggleSearch()
                : null,
          ),
          
          const SizedBox(width: AppConstants.spacingSmall),
          
          // 主题切换按钮
          _ToolBarButton(
            icon: themeProvider.isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            tooltip: themeProvider.isDarkMode ? '浅色模式' : '深色模式',
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
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

  const _ToolBarButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.isActive = false,
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
                child: Icon(
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
