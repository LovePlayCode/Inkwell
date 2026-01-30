import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/heading.dart';
import '../providers/document_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

/// 文档大纲组件
class OutlinePanel extends StatelessWidget {
  final List<Heading> headings;
  final Function(Heading) onHeadingTap;
  final int? activeHeadingIndex;
  final double width;

  const OutlinePanel({
    super.key,
    required this.headings,
    required this.onHeadingTap,
    this.activeHeadingIndex,
    this.width = 240,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFAFAFA),
        border: Border(
          right: BorderSide(
            color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          _buildHeader(theme, isDark),
          // 大纲列表
          Expanded(
            child: headings.isEmpty
                ? _buildEmptyState(theme)
                : _buildOutlineList(theme, isDark),
          ),
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMedium,
        vertical: AppConstants.spacingSmall + 4,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2C2C2E).withValues(alpha: 0.5)
            : const Color(0xFFF5F5F7).withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.list_alt_rounded,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            '大纲',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${headings.length}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              decoration: BoxDecoration(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
              ),
              child: Icon(
                Icons.format_list_bulleted_rounded,
                size: 32,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              '暂无标题',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppConstants.spacingXSmall),
            Text(
              '使用 # 标记创建标题',
              style: TextStyle(
                fontSize: 11,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建大纲列表
  Widget _buildOutlineList(ThemeData theme, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
      itemCount: headings.length,
      itemBuilder: (context, index) {
        final heading = headings[index];
        final isActive = activeHeadingIndex == index;

        return _OutlineItem(
          key: ValueKey('heading_$index'),
          heading: heading,
          isActive: isActive,
          isDark: isDark,
          onTap: () => onHeadingTap(heading),
        );
      },
    );
  }
}

/// 大纲项组件
class _OutlineItem extends StatefulWidget {
  final Heading heading;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _OutlineItem({
    super.key,
    required this.heading,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_OutlineItem> createState() => _OutlineItemState();
}

class _OutlineItemState extends State<_OutlineItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 根据标题级别计算缩进
    final indent = (widget.heading.level - 1) * 14.0;

    // 根据标题级别调整字体大小和粗细
    final fontSize = _getFontSize(widget.heading.level);
    final fontWeight = _getFontWeight(widget.heading.level);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: AppConstants.animationFast,
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingSmall,
              vertical: 2,
            ),
            padding: EdgeInsets.only(
              left: AppConstants.spacingSmall + indent,
              right: AppConstants.spacingSmall,
              top: 8,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? AppTheme.primaryColor.withValues(alpha: 0.15)
                  : (_isHovered
                      ? (widget.isDark
                          ? const Color(0xFF3A3A3C).withValues(alpha: 0.5)
                          : const Color(0xFFE5E5EA).withValues(alpha: 0.5))
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              border: widget.isActive
                  ? Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // 级别指示器
                _LevelIndicator(
                  level: widget.heading.level,
                  isActive: widget.isActive,
                ),
                const SizedBox(width: 10),
                // 标题文本
                Expanded(
                  child: Text(
                    widget.heading.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: widget.isActive
                          ? AppTheme.primaryColor
                          : theme.textTheme.bodyMedium?.color?.withValues(
                              alpha: 1.0 - (widget.heading.level - 1) * 0.08,
                            ),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getFontSize(int level) {
    switch (level) {
      case 1:
        return 13.5;
      case 2:
        return 13;
      case 3:
        return 12.5;
      default:
        return 12;
    }
  }

  FontWeight _getFontWeight(int level) {
    switch (level) {
      case 1:
        return FontWeight.w600;
      case 2:
        return FontWeight.w500;
      default:
        return FontWeight.w400;
    }
  }
}

/// 级别指示器
class _LevelIndicator extends StatelessWidget {
  final int level;
  final bool isActive;

  const _LevelIndicator({
    required this.level,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = 6.0 - (level - 1) * 0.5;

    return Container(
      width: size.clamp(4.0, 6.0),
      height: size.clamp(4.0, 6.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? AppTheme.primaryColor
            : theme.textTheme.bodySmall?.color?.withValues(
                alpha: 0.5 - (level - 1) * 0.08,
              ),
      ),
    );
  }
}

/// 可调整大小的大纲面板
class ResizableOutlinePanel extends StatefulWidget {
  const ResizableOutlinePanel({super.key});

  @override
  State<ResizableOutlinePanel> createState() => _ResizableOutlinePanelState();
}

class _ResizableOutlinePanelState extends State<ResizableOutlinePanel>
    with SingleTickerProviderStateMixin {
  bool _isResizing = false;
  late AnimationController _collapseController;
  double _currentWidth = AppConstants.outlineWidthDefault;

  @override
  void initState() {
    super.initState();
    _collapseController = AnimationController(
      duration: AppConstants.animationNormal,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _collapseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = context.watch<DocumentProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!documentProvider.hasDocument) {
      return const SizedBox.shrink();
    }

    final headings = HeadingParser.parse(documentProvider.content);
    final isExpanded = documentProvider.isOutlinePanelExpanded;

    // 控制折叠动画
    if (isExpanded) {
      _collapseController.reverse();
    } else {
      _collapseController.forward();
    }

    return AnimatedBuilder(
      animation: _collapseController,
      builder: (context, child) {
        final animatedWidth = isExpanded
            ? _currentWidth
            : AppConstants.outlineCollapsedWidth;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppConstants.animationNormal,
              width: animatedWidth,
              curve: Curves.easeInOut,
              child: isExpanded
                  ? OutlinePanel(
                      headings: headings,
                      onHeadingTap: (heading) {
                        documentProvider.scrollToHeading(heading);
                      },
                      activeHeadingIndex: documentProvider.activeHeadingIndex,
                      width: _currentWidth,
                    )
                  : _CollapsedOutlineBar(
                      count: headings.length,
                      theme: theme,
                      isDark: isDark,
                      onExpand: () =>
                          documentProvider.setOutlinePanelExpanded(true),
                    ),
            ),
            // 调整大小手柄
            if (isExpanded)
              _ResizeHandle(
                isDark: isDark,
                isResizing: _isResizing,
                onResizeStart: () => setState(() => _isResizing = true),
                onResizeEnd: () => setState(() => _isResizing = false),
                onResize: (delta) {
                  setState(() {
                    _currentWidth = (_currentWidth + delta).clamp(
                      AppConstants.outlineWidthMin,
                      AppConstants.outlineWidthMax,
                    );
                  });
                },
              ),
          ],
        );
      },
    );
  }
}

/// 折叠状态的大纲栏
class _CollapsedOutlineBar extends StatelessWidget {
  final int count;
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onExpand;

  const _CollapsedOutlineBar({
    required this.count,
    required this.theme,
    required this.isDark,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFAFAFA),
        border: Border(
          right: BorderSide(
            color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppConstants.spacingSmall),
          Tooltip(
            message: '展开大纲',
            child: IconButton(
              onPressed: onExpand,
              icon: Icon(
                Icons.chevron_right_rounded,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          RotatedBox(
            quarterTurns: 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.list_alt_rounded,
                  size: 12,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '大纲 ($count)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color:
                        theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 调整大小手柄
class _ResizeHandle extends StatefulWidget {
  final bool isDark;
  final bool isResizing;
  final VoidCallback onResizeStart;
  final VoidCallback onResizeEnd;
  final Function(double) onResize;

  const _ResizeHandle({
    required this.isDark,
    required this.isResizing,
    required this.onResizeStart,
    required this.onResizeEnd,
    required this.onResize,
  });

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = _isHovered || widget.isResizing;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onHorizontalDragStart: (_) => widget.onResizeStart(),
        onHorizontalDragEnd: (_) => widget.onResizeEnd(),
        onHorizontalDragUpdate: (details) => widget.onResize(details.delta.dx),
        child: AnimatedContainer(
          duration: AppConstants.animationFast,
          width: 6,
          color: isActive
              ? AppTheme.primaryColor.withValues(alpha: 0.5)
              : Colors.transparent,
          child: Center(
            child: AnimatedContainer(
              duration: AppConstants.animationFast,
              width: 2,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primaryColor
                    : (widget.isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 移动端大纲面板
class MobileOutlinePanel extends StatelessWidget {
  final DocumentProvider documentProvider;
  final bool isDark;
  final VoidCallback onClose;

  const MobileOutlinePanel({
    super.key,
    required this.documentProvider,
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headings = HeadingParser.parse(documentProvider.content);

    return Column(
      children: [
        // 头部
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMedium,
            vertical: AppConstants.spacingMedium,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFF5F5F7),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? const Color(0xFF3A3A3C)
                    : const Color(0xFFE5E5EA),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.list_alt_rounded,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Text(
                '文档大纲',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                ),
                child: Text(
                  '${headings.length} 个标题',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 列表
        Expanded(
          child: headings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.format_list_bulleted_rounded,
                        size: 48,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      Text(
                        '暂无标题',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingSmall,
                  ),
                  itemCount: headings.length,
                  itemBuilder: (context, index) {
                    final heading = headings[index];
                    final isActive =
                        documentProvider.activeHeadingIndex == index;

                    return _MobileOutlineItem(
                      heading: heading,
                      isActive: isActive,
                      isDark: isDark,
                      onTap: () {
                        documentProvider.scrollToHeading(heading);
                        onClose();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// 移动端大纲项
class _MobileOutlineItem extends StatelessWidget {
  final Heading heading;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _MobileOutlineItem({
    required this.heading,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indent = (heading.level - 1) * 16.0;

    return ListTile(
      contentPadding: EdgeInsets.only(
        left: AppConstants.spacingMedium + indent,
        right: AppConstants.spacingMedium,
      ),
      leading: _LevelIndicator(level: heading.level, isActive: isActive),
      title: Text(
        heading.text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          fontWeight: heading.level == 1 ? FontWeight.w600 : FontWeight.w400,
          color: isActive
              ? AppTheme.primaryColor
              : theme.textTheme.bodyMedium?.color,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppTheme.primaryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      onTap: onTap,
    );
  }
}

/// 可折叠的大纲面板包装器（兼容旧代码）
class CollapsibleOutlinePanel extends StatelessWidget {
  const CollapsibleOutlinePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResizableOutlinePanel();
  }
}
