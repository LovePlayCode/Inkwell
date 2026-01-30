import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import '../widgets/tool_bar.dart';
import '../widgets/drop_zone.dart';
import '../widgets/markdown_viewer.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/outline_panel.dart';
import '../widgets/reading_progress.dart';
import '../utils/constants.dart';

/// 主页面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late AnimationController _loadingAnimationController;

  @override
  void initState() {
    super.initState();
    _loadingAnimationController = AnimationController(
      duration: AppConstants.animationNormal,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = context.watch<DocumentProvider>();
    final theme = Theme.of(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    // 控制加载动画
    if (documentProvider.isLoading) {
      _loadingAnimationController.forward();
    } else {
      _loadingAnimationController.reverse();
    }

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        body: DropZone(
          child: Column(
            children: [
              // 顶部工具栏
              const ToolBar(),

              // 阅读进度条
              if (documentProvider.hasDocument)
                const ReadingProgressBar(),

              // 主内容区
              Expanded(
                child: _buildMainContent(
                  context,
                  documentProvider,
                  theme,
                  isMobile,
                ),
              ),
            ],
          ),
        ),
        // 移动端抽屉式大纲
        drawer: isMobile && documentProvider.hasDocument
            ? _buildMobileOutlineDrawer(context, documentProvider, theme)
            : null,
      ),
    );
  }

  /// 构建主内容区
  Widget _buildMainContent(
    BuildContext context,
    DocumentProvider documentProvider,
    ThemeData theme,
    bool isMobile,
  ) {
    return Row(
      children: [
        // 左侧大纲面板（非移动端）
        if (!isMobile && documentProvider.hasDocument)
          const ResizableOutlinePanel(),

        // 右侧内容区
        Expanded(
          child: Stack(
            children: [
              // 内容或空状态
              AnimatedSwitcher(
                duration: AppConstants.animationNormal,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: documentProvider.hasDocument
                    ? const MarkdownViewer()
                    : EmptyState(
                        key: const ValueKey('empty'),
                        onOpenFile: () => documentProvider.openFile(),
                      ),
              ),

              // 加载指示器
              _buildLoadingOverlay(theme, documentProvider.isLoading),

              // 搜索栏
              if (documentProvider.isSearchVisible)
                const Positioned(
                  top: AppConstants.spacingMedium,
                  right: AppConstants.spacingMedium,
                  child: custom.SearchBar(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建加载遮罩层
  Widget _buildLoadingOverlay(ThemeData theme, bool isLoading) {
    return AnimatedBuilder(
      animation: _loadingAnimationController,
      builder: (context, child) {
        if (_loadingAnimationController.value == 0) {
          return const SizedBox.shrink();
        }
        return Positioned.fill(
          child: FadeTransition(
            opacity: _loadingAnimationController,
            child: Container(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LoadingIndicator(
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    Text(
                      '加载中...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建移动端大纲抽屉
  Widget _buildMobileOutlineDrawer(
    BuildContext context,
    DocumentProvider documentProvider,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return Drawer(
      child: SafeArea(
        child: MobileOutlinePanel(
          documentProvider: documentProvider,
          isDark: isDark,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// 处理键盘事件
  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return;
    }

    final documentProvider = context.read<DocumentProvider>();

    // Command + F 打开搜索
    if (event.logicalKey == LogicalKeyboardKey.keyF &&
        HardwareKeyboard.instance.isMetaPressed) {
      documentProvider.showSearch();
      return;
    }

    // ESC 关闭搜索
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (documentProvider.isSearchVisible) {
        documentProvider.hideSearch();
      }
      return;
    }

    // Command + B 切换大纲面板
    if (event.logicalKey == LogicalKeyboardKey.keyB &&
        HardwareKeyboard.instance.isMetaPressed) {
      documentProvider.toggleOutlinePanel();
      return;
    }
  }
}

/// 加载指示器组件
class _LoadingIndicator extends StatefulWidget {
  final Color color;

  const _LoadingIndicator({required this.color});

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _LoadingPainter(
              progress: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

/// 加载指示器绘制器
class _LoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LoadingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // 绘制旋转弧线
    const startAngle = -3.14159 / 2;
    final sweepAngle = 3.14159 * 1.5 * (0.3 + 0.7 * (1 - (progress * 2 - 1).abs()));
    final rotation = progress * 3.14159 * 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_LoadingPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

/// 空状态组件
class EmptyState extends StatefulWidget {
  final VoidCallback onOpenFile;

  const EmptyState({
    super.key,
    required this.onOpenFile,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationSlow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
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

    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: child,
              ),
            ),
          );
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 动态图标容器
                _AnimatedIconContainer(
                  isDark: isDark,
                  primaryColor: theme.colorScheme.primary,
                  secondaryColor: theme.colorScheme.secondary,
                ),

                const SizedBox(height: AppConstants.spacingXLarge),

                // 标题
                Text(
                  '开始阅读',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingSmall),

                // 描述
                Text(
                  '拖拽 Markdown 文件到此处\n或点击下方按钮选择文件',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXLarge),

                // 打开按钮
                _OpenFileButton(
                  onPressed: widget.onOpenFile,
                  primaryColor: theme.colorScheme.primary,
                ),

                const SizedBox(height: AppConstants.spacingMedium),

                // 快捷键提示
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMedium,
                    vertical: AppConstants.spacingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.keyboard_outlined,
                        size: 16,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Text(
                        '支持 ⌘F 搜索 · ⌘B 切换大纲',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 动画图标容器
class _AnimatedIconContainer extends StatefulWidget {
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;

  const _AnimatedIconContainer({
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<_AnimatedIconContainer> createState() => _AnimatedIconContainerState();
}

class _AnimatedIconContainerState extends State<_AnimatedIconContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.primaryColor.withValues(alpha: 0.15),
              widget.secondaryColor.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: widget.primaryColor.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 背景装饰
            Positioned(
              right: 15,
              bottom: 15,
              child: Icon(
                Icons.auto_awesome,
                size: 20,
                color: widget.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            // 主图标
            Icon(
              Icons.description_outlined,
              size: 56,
              color: widget.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// 打开文件按钮
class _OpenFileButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color primaryColor;

  const _OpenFileButton({
    required this.onPressed,
    required this.primaryColor,
  });

  @override
  State<_OpenFileButton> createState() => _OpenFileButtonState();
}

class _OpenFileButtonState extends State<_OpenFileButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        transform: Matrix4.identity()..setEntry(0, 0, _isHovered ? 1.02 : 1.0)..setEntry(1, 1, _isHovered ? 1.02 : 1.0),
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: AnimatedRotation(
            duration: AppConstants.animationNormal,
            turns: _isHovered ? 0.05 : 0,
            child: const Icon(Icons.folder_open_outlined, size: 20),
          ),
          label: const Text('打开文件'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingLarge,
              vertical: AppConstants.spacingMedium,
            ),
            elevation: _isHovered ? 8 : 0,
            shadowColor: widget.primaryColor.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
