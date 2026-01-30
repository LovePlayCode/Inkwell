import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

/// 文件拖拽区域组件
class DropZone extends StatefulWidget {
  final Widget child;

  const DropZone({
    super.key,
    required this.child,
  });

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone>
    with SingleTickerProviderStateMixin {
  bool _isDragging = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationNormal,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
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
    final isDark = theme.brightness == Brightness.dark;

    return DropTarget(
      onDragEntered: (details) {
        setState(() => _isDragging = true);
        _animationController.forward();
      },
      onDragExited: (details) {
        setState(() => _isDragging = false);
        _animationController.reverse();
      },
      onDragDone: (details) async {
        setState(() => _isDragging = false);
        _animationController.reverse();

        if (details.files.isNotEmpty) {
          final file = details.files.first;
          final documentProvider = context.read<DocumentProvider>();
          await documentProvider.loadFile(file.path);
        }
      },
      child: Stack(
        children: [
          widget.child,

          // 拖拽覆盖层
          if (_isDragging)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _opacityAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(AppConstants.spacingMedium),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.08),
                        AppTheme.primaryDark.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge,
                    ),
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: _DragOverlayContent(
                      primaryColor: theme.colorScheme.primary,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 拖拽覆盖层内容
class _DragOverlayContent extends StatefulWidget {
  final Color primaryColor;
  final bool isDark;

  const _DragOverlayContent({
    required this.primaryColor,
    required this.isDark,
  });

  @override
  State<_DragOverlayContent> createState() => _DragOverlayContentState();
}

class _DragOverlayContentState extends State<_DragOverlayContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _bounceAnimation.value),
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            decoration: BoxDecoration(
              color: widget.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.file_download_outlined,
              size: 56,
              color: widget.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingLarge),
        Text(
          '释放以打开文件',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: widget.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Text(
          '支持 .md 文件',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: widget.primaryColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
