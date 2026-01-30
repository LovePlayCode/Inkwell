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

  const OutlinePanel({
    super.key,
    required this.headings,
    required this.onHeadingTap,
    this.activeHeadingIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: AppConstants.outlineWidth,
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
          Text(
            '${headings.length}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
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
            Icon(
              Icons.format_list_bulleted_rounded,
              size: 32,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              '暂无标题',
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
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
    required this.heading,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_OutlineItem> createState() => _OutlineItemState();
}

class _OutlineItemState extends State<_OutlineItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 根据标题级别计算缩进
    final indent = (widget.heading.level - 1) * 12.0;
    
    // 根据标题级别调整字体大小和粗细
    final fontSize = _getFontSize(widget.heading.level);
    final fontWeight = _getFontWeight(widget.heading.level);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppConstants.animationFast,
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingSmall,
            vertical: 1,
          ),
          padding: EdgeInsets.only(
            left: AppConstants.spacingSmall + indent,
            right: AppConstants.spacingSmall,
            top: 6,
            bottom: 6,
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
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isActive
                      ? AppTheme.primaryColor
                      : theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.4 - (widget.heading.level - 1) * 0.05,
                        ),
                ),
              ),
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
                            alpha: 1.0 - (widget.heading.level - 1) * 0.1,
                          ),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getFontSize(int level) {
    switch (level) {
      case 1:
        return 13;
      case 2:
        return 12.5;
      case 3:
        return 12;
      default:
        return 11.5;
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

/// 可折叠的大纲面板包装器
class CollapsibleOutlinePanel extends StatefulWidget {
  const CollapsibleOutlinePanel({super.key});

  @override
  State<CollapsibleOutlinePanel> createState() => _CollapsibleOutlinePanelState();
}

class _CollapsibleOutlinePanelState extends State<CollapsibleOutlinePanel> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final documentProvider = context.watch<DocumentProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!documentProvider.hasDocument) {
      return const SizedBox.shrink();
    }

    final headings = HeadingParser.parse(documentProvider.content);

    return AnimatedContainer(
      duration: AppConstants.animationNormal,
      width: _isExpanded ? AppConstants.outlineWidth : 40,
      child: _isExpanded
          ? OutlinePanel(
              headings: headings,
              onHeadingTap: (heading) {
                documentProvider.scrollToHeading(heading);
              },
              activeHeadingIndex: documentProvider.activeHeadingIndex,
            )
          : _buildCollapsedBar(theme, isDark, headings.length),
    );
  }

  Widget _buildCollapsedBar(ThemeData theme, bool isDark, int count) {
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
          IconButton(
            onPressed: () => setState(() => _isExpanded = true),
            icon: Icon(
              Icons.chevron_right_rounded,
              color: theme.textTheme.bodyMedium?.color,
            ),
            tooltip: '展开大纲',
          ),
          const SizedBox(height: 4),
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              '大纲 ($count)',
              style: TextStyle(
                fontSize: 11,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
