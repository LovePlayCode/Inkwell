import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
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

class _DropZoneState extends State<DropZone> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropTarget(
      onDragEntered: (details) {
        setState(() => _isDragging = true);
      },
      onDragExited: (details) {
        setState(() => _isDragging = false);
      },
      onDragDone: (details) async {
        setState(() => _isDragging = false);

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
              child: AnimatedOpacity(
                duration: AppConstants.animationFast,
                opacity: _isDragging ? 1.0 : 0.0,
                child: Container(
                  margin: const EdgeInsets.all(AppConstants.spacingMedium),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                      // 虚线效果使用实线代替，因为 Flutter 不直接支持虚线
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.file_download_outlined,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: AppConstants.spacingMedium),
                        Text(
                          '释放以打开文件',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
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
