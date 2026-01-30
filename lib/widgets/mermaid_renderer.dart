import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

/// Mermaid 图表渲染器 - 使用 InAppWebView 渲染真实图表
class MermaidRenderer extends StatefulWidget {
  final String code;
  final bool isDark;
  final double? height;

  const MermaidRenderer({
    super.key,
    required this.code,
    required this.isDark,
    this.height,
  });

  @override
  State<MermaidRenderer> createState() => _MermaidRendererState();
}

class _MermaidRendererState extends State<MermaidRenderer> {
  InAppWebViewController? _webViewController;
  double _contentHeight = 200; // 默认高度
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void didUpdateWidget(MermaidRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code || oldWidget.isDark != widget.isDark) {
      _loadMermaidContent();
    }
  }

  /// 生成 Mermaid HTML 内容
  String _generateHtmlContent() {
    final bgColor = widget.isDark ? '#1C1C1E' : '#FFFFFF';
    final textColor = widget.isDark ? '#F5F5F7' : '#1D1D1F';
    final theme = widget.isDark ? 'dark' : 'default';
    
    // 转义代码中的特殊字符
    final escapedCode = widget.code
        .replaceAll('\\', '\\\\')
        .replaceAll('`', '\\`')
        .replaceAll('\$', '\\\$');

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    html, body {
      background-color: $bgColor;
      color: $textColor;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      overflow: hidden;
    }
    #container {
      display: flex;
      justify-content: center;
      align-items: center;
      padding: 16px;
      min-height: 100px;
    }
    .mermaid {
      display: flex;
      justify-content: center;
    }
    .mermaid svg {
      max-width: 100%;
      height: auto;
    }
    .error {
      color: #ff6b6b;
      padding: 20px;
      text-align: center;
      font-size: 14px;
    }
    .loading {
      color: $textColor;
      padding: 20px;
      text-align: center;
      font-size: 14px;
      opacity: 0.6;
    }
  </style>
</head>
<body>
  <div id="container">
    <div class="mermaid">
$escapedCode
    </div>
  </div>
  <script>
    mermaid.initialize({
      startOnLoad: true,
      theme: '$theme',
      securityLevel: 'loose',
      flowchart: {
        useMaxWidth: true,
        htmlLabels: true,
        curve: 'basis'
      },
      sequence: {
        useMaxWidth: true,
        diagramMarginX: 10,
        diagramMarginY: 10
      }
    });

    // 渲染完成后通知 Flutter
    mermaid.run().then(() => {
      setTimeout(() => {
        const container = document.getElementById('container');
        const height = container.scrollHeight;
        window.flutter_inappwebview.callHandler('onContentHeight', height);
      }, 100);
    }).catch((error) => {
      window.flutter_inappwebview.callHandler('onError', error.message || 'Unknown error');
    });
  </script>
</body>
</html>
''';
  }

  /// 加载 Mermaid 内容
  void _loadMermaidContent() {
    if (_webViewController == null) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    final html = _generateHtmlContent();
    _webViewController!.loadData(
      data: html,
      mimeType: 'text/html',
      encoding: 'utf-8',
    );
  }

  @override
  Widget build(BuildContext context) {
    final chartType = MermaidUtils.getChartType(widget.code);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: widget.isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            _buildHeader(chartType),
            // WebView 内容
            SizedBox(
              height: widget.height ?? _contentHeight,
              child: Stack(
                children: [
                  InAppWebView(
                    initialSettings: InAppWebViewSettings(
                      transparentBackground: false,
                      javaScriptEnabled: true,
                      disableHorizontalScroll: true,
                      disableVerticalScroll: true,
                      supportZoom: false,
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                      
                      // 注册高度回调
                      controller.addJavaScriptHandler(
                        handlerName: 'onContentHeight',
                        callback: (args) {
                          if (args.isNotEmpty && args[0] is num) {
                            final height = (args[0] as num).toDouble();
                            if (mounted && height > 0) {
                              setState(() {
                                _contentHeight = height.clamp(100, 600);
                                _isLoading = false;
                              });
                            }
                          }
                          return null;
                        },
                      );
                      
                      // 注册错误回调
                      controller.addJavaScriptHandler(
                        handlerName: 'onError',
                        callback: (args) {
                          if (mounted) {
                            setState(() {
                              _hasError = true;
                              _errorMessage = args.isNotEmpty ? args[0].toString() : 'Render error';
                              _isLoading = false;
                            });
                          }
                          return null;
                        },
                      );
                      
                      _loadMermaidContent();
                    },
                    onLoadStop: (controller, url) {
                      // 页面加载完成
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted && _isLoading) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      });
                    },
                    onReceivedError: (controller, request, error) {
                      if (mounted) {
                        setState(() {
                          _hasError = true;
                          _errorMessage = error.description;
                          _isLoading = false;
                        });
                      }
                    },
                  ),
                  // 加载指示器
                  if (_isLoading)
                    Positioned.fill(
                      child: Container(
                        color: widget.isDark 
                            ? const Color(0xFF2C2C2E) 
                            : const Color(0xFFF5F5F7),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '渲染图表中...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.isDark 
                                      ? const Color(0xFFF5F5F7).withValues(alpha: 0.6)
                                      : const Color(0xFF1D1D1F).withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // 错误显示
                  if (_hasError)
                    Positioned.fill(
                      child: Container(
                        color: widget.isDark 
                            ? const Color(0xFF2C2C2E) 
                            : const Color(0xFFF5F5F7),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 32,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '图表渲染失败',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.red.shade400,
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _errorMessage!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.isDark 
                                      ? const Color(0xFFF5F5F7).withValues(alpha: 0.6)
                                      : const Color(0xFF1D1D1F).withValues(alpha: 0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 12),
                            // 显示原始代码
                            Expanded(
                              child: SingleChildScrollView(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: widget.isDark 
                                        ? const Color(0xFF1C1C1E) 
                                        : const Color(0xFFE5E5EA),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: SelectableText(
                                    widget.code,
                                    style: TextStyle(
                                      fontFamily: 'SF Mono, Menlo, Monaco, monospace',
                                      fontSize: 12,
                                      color: widget.isDark 
                                          ? const Color(0xFFF5F5F7) 
                                          : const Color(0xFF1D1D1F),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建标题栏
  Widget _buildHeader(String chartType) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMedium,
        vertical: AppConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF3A3A3C).withValues(alpha: 0.5)
            : const Color(0xFFE5E5EA).withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: widget.isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForChartType(chartType),
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            chartType,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: widget.isDark 
                  ? const Color(0xFFF5F5F7).withValues(alpha: 0.8)
                  : const Color(0xFF1D1D1F).withValues(alpha: 0.8),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'mermaid',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForChartType(String chartType) {
    switch (chartType) {
      case 'Flowchart':
        return Icons.account_tree_outlined;
      case 'Sequence Diagram':
        return Icons.swap_horiz;
      case 'Class Diagram':
        return Icons.class_outlined;
      case 'State Diagram':
        return Icons.circle_outlined;
      case 'ER Diagram':
        return Icons.table_chart_outlined;
      case 'User Journey':
        return Icons.route;
      case 'Gantt Chart':
        return Icons.view_timeline;
      case 'Pie Chart':
        return Icons.pie_chart_outline;
      case 'Git Graph':
        return Icons.call_split;
      default:
        return Icons.auto_graph;
    }
  }
}

/// 检测是否为 Mermaid 代码块
class MermaidUtils {
  /// 支持的 Mermaid 图表类型
  static const List<String> supportedTypes = [
    'mermaid',
    'flowchart',
    'graph',
    'sequenceDiagram',
    'classDiagram',
    'stateDiagram',
    'erDiagram',
    'journey',
    'gantt',
    'pie',
    'gitGraph',
  ];

  /// 检测代码块是否为 Mermaid 图表
  static bool isMermaidCode(String language, String code) {
    final lang = language.toLowerCase().trim();
    
    // 直接标记为 mermaid
    if (lang == 'mermaid') {
      return true;
    }

    // 检查代码内容是否以支持的图表类型开头
    final trimmedCode = code.trim().toLowerCase();
    for (final type in supportedTypes) {
      if (trimmedCode.startsWith(type.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  /// 获取图表类型名称
  static String getChartType(String code) {
    final trimmedCode = code.trim().toLowerCase();
    
    if (trimmedCode.startsWith('flowchart') || trimmedCode.startsWith('graph')) {
      return 'Flowchart';
    } else if (trimmedCode.startsWith('sequencediagram')) {
      return 'Sequence Diagram';
    } else if (trimmedCode.startsWith('classdiagram')) {
      return 'Class Diagram';
    } else if (trimmedCode.startsWith('statediagram')) {
      return 'State Diagram';
    } else if (trimmedCode.startsWith('erdiagram')) {
      return 'ER Diagram';
    } else if (trimmedCode.startsWith('journey')) {
      return 'User Journey';
    } else if (trimmedCode.startsWith('gantt')) {
      return 'Gantt Chart';
    } else if (trimmedCode.startsWith('pie')) {
      return 'Pie Chart';
    } else if (trimmedCode.startsWith('gitgraph')) {
      return 'Git Graph';
    }
    
    return 'Diagram';
  }
}
