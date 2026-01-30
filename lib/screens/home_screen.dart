import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import '../widgets/tool_bar.dart';
import '../widgets/drop_zone.dart';
import '../widgets/markdown_viewer.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/outline_panel.dart';
import '../utils/constants.dart';

/// 主页面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = context.watch<DocumentProvider>();
    final theme = Theme.of(context);

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
              
              // 主内容区
              Expanded(
                child: Row(
                  children: [
                    // 左侧大纲面板
                    if (documentProvider.hasDocument)
                      const CollapsibleOutlinePanel(),
                    
                    // 右侧内容区
                    Expanded(
                      child: Stack(
                        children: [
                          // 内容或空状态
                          if (documentProvider.hasDocument)
                            const MarkdownViewer()
                          else
                            EmptyState(
                              onOpenFile: () => documentProvider.openFile(),
                            ),
                          
                          // 加载指示器
                          if (documentProvider.isLoading)
                            Positioned.fill(
                              child: Container(
                                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(height: AppConstants.spacingMedium),
                                      Text(
                                        '加载中...',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          
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
                ),
              ),
            ],
          ),
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
  }
}

/// 空状态组件
class EmptyState extends StatelessWidget {
  final VoidCallback onOpenFile;

  const EmptyState({
    super.key,
    required this.onOpenFile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge * 2),
            ),
            child: Icon(
              Icons.description_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: AppConstants.spacingLarge),
          
          // 标题
          Text(
            '开始阅读',
            style: theme.textTheme.headlineMedium,
          ),
          
          const SizedBox(height: AppConstants.spacingSmall),
          
          // 描述
          Text(
            '拖拽 .md 文件到此处，或点击下方按钮打开',
            style: theme.textTheme.bodyMedium,
          ),
          
          const SizedBox(height: AppConstants.spacingLarge),
          
          // 打开按钮
          ElevatedButton.icon(
            onPressed: onOpenFile,
            icon: const Icon(Icons.folder_open_outlined, size: 20),
            label: const Text('打开文件'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLarge,
                vertical: AppConstants.spacingMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
