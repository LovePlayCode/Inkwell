import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

/// 阅读进度条
class ReadingProgressBar extends StatelessWidget {
  const ReadingProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final documentProvider = context.watch<DocumentProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 3,
      child: AnimatedBuilder(
        animation: documentProvider,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: documentProvider.readingProgress,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor.withValues(alpha: 0.8),
            ),
            minHeight: 3,
          );
        },
      ),
    );
  }
}

/// 阅读进度指示器（浮动显示）
class ReadingProgressIndicator extends StatefulWidget {
  final double progress;
  final bool isVisible;

  const ReadingProgressIndicator({
    super.key,
    required this.progress,
    this.isVisible = true,
  });

  @override
  State<ReadingProgressIndicator> createState() =>
      _ReadingProgressIndicatorState();
}

class _ReadingProgressIndicatorState extends State<ReadingProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationNormal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ReadingProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentage = (widget.progress * 100).toInt();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF2C2C2E)
              : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 进度环
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: widget.progress,
                strokeWidth: 3,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            // 百分比文字
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 垂直滚动进度条
class VerticalScrollProgress extends StatelessWidget {
  final double progress;

  const VerticalScrollProgress({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 4,
      height: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: AnimatedContainer(
          duration: AppConstants.animationFast,
          width: 4,
          height: progress * 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
