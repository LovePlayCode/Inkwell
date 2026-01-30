import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import '../utils/constants.dart';

/// 搜索栏组件
class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // 初始化动画
    _animationController = AnimationController(
      duration: AppConstants.animationNormal,
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(begin: -20, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    // 播放入场动画
    _animationController.forward();
    
    // 自动聚焦
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final documentProvider = context.watch<DocumentProvider>();
    final searchResult = documentProvider.searchResult;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: AppConstants.searchBarWidth,
        height: AppConstants.searchBarHeight,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 搜索图标
            Padding(
              padding: const EdgeInsets.only(left: AppConstants.spacingMedium),
              child: Icon(
                Icons.search,
                size: 20,
                color: theme.iconTheme.color,
              ),
            ),
            
            // 搜索输入框
            Expanded(
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: _handleKeyEvent,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: '搜索...',
                    hintStyle: TextStyle(
                      color: theme.iconTheme.color?.withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSmall,
                    ),
                    isDense: true,
                  ),
                  onChanged: _onSearchChanged,
                  onSubmitted: (_) => _onNextMatch(),
                ),
              ),
            ),
            
            // 匹配数量显示
            if (searchResult.hasMatches || documentProvider.searchQuery.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingSmall,
                ),
                child: Text(
                  searchResult.hasMatches
                      ? '${searchResult.currentMatchNumber}/${searchResult.totalMatches}'
                      : '无匹配',
                  style: TextStyle(
                    fontSize: 12,
                    color: searchResult.hasMatches
                        ? theme.iconTheme.color
                        : theme.colorScheme.error,
                  ),
                ),
              ),
            
            // 导航按钮
            if (searchResult.hasMatches) ...[
              _NavigationButton(
                icon: Icons.keyboard_arrow_up,
                onPressed: _onPreviousMatch,
                tooltip: '上一个 (Shift+Enter)',
              ),
              _NavigationButton(
                icon: Icons.keyboard_arrow_down,
                onPressed: _onNextMatch,
                tooltip: '下一个 (Enter)',
              ),
            ],
            
            // 关闭按钮
            _NavigationButton(
              icon: Icons.close,
              onPressed: _onClose,
              tooltip: '关闭 (ESC)',
            ),
            
            const SizedBox(width: AppConstants.spacingXSmall),
          ],
        ),
      ),
    );
  }

  /// 搜索内容变化，带防抖
  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppConstants.searchDebounceDelay, () {
      context.read<DocumentProvider>().search(value);
    });
  }

  /// 处理键盘事件
  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return;
    }

    // ESC 关闭
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _onClose();
      return;
    }

    // Enter 下一个
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        _onPreviousMatch();
      } else {
        _onNextMatch();
      }
      return;
    }
  }

  /// 下一个匹配
  void _onNextMatch() {
    context.read<DocumentProvider>().nextMatch();
  }

  /// 上一个匹配
  void _onPreviousMatch() {
    context.read<DocumentProvider>().previousMatch();
  }

  /// 关闭搜索栏
  void _onClose() {
    _animationController.reverse().then((_) {
      context.read<DocumentProvider>().hideSearch();
    });
  }
}

/// 导航按钮
class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _NavigationButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingXSmall),
            child: Icon(
              icon,
              size: 20,
              color: theme.iconTheme.color,
            ),
          ),
        ),
      ),
    );
  }
}
