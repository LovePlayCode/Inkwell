import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:markdown/markdown.dart' as md;
import '../providers/document_provider.dart';
import '../models/heading.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';
import 'mermaid_renderer.dart';

/// Markdown 内容查看器（带搜索高亮和 Mermaid 支持）
class MarkdownViewer extends StatefulWidget {
  const MarkdownViewer({super.key});

  @override
  State<MarkdownViewer> createState() => _MarkdownViewerState();
}

class _MarkdownViewerState extends State<MarkdownViewer> {
  final ScrollController _scrollController = ScrollController();
  int _lastMatchIndex = -1;
  Heading? _lastTargetHeading;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 监听滚动事件，更新阅读进度
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    final currentScroll = _scrollController.offset;
    final progress = (currentScroll / maxScroll).clamp(0.0, 1.0);

    // 使用 WidgetsBinding 延迟更新，避免在 build 过程中更新状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DocumentProvider>().updateReadingProgress(progress);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final documentProvider = context.watch<DocumentProvider>();
    final isDark = theme.brightness == Brightness.dark;

    // 处理滚动事件
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMatch(documentProvider);
      _scrollToTargetHeading(documentProvider);
    });

    return RepaintBoundary(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.contentMaxWidth,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveLayout.isMobile(context)
                    ? AppConstants.spacingMedium
                    : AppConstants.spacingLarge,
                vertical: AppConstants.spacingMedium,
              ),
              child: _buildMarkdownContent(
                context,
                documentProvider.content,
                documentProvider.searchQuery,
                documentProvider.searchResult.matches.map((m) => m.start).toList(),
                documentProvider.searchResult.currentIndex,
                theme,
                isDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 滚动到目标标题
  void _scrollToTargetHeading(DocumentProvider documentProvider) {
    final targetHeading = documentProvider.targetHeading;
    if (targetHeading == null || targetHeading == _lastTargetHeading) {
      return;
    }

    _lastTargetHeading = targetHeading;

    // 基于字符位置估算滚动位置
    if (_scrollController.hasClients) {
      final contentLength = documentProvider.content.length;
      if (contentLength > 0) {
        final scrollPercentage = targetHeading.charIndex / contentLength;
        final maxScroll = _scrollController.position.maxScrollExtent;
        final targetScroll = maxScroll * scrollPercentage;

        _scrollController.animateTo(
          targetScroll.clamp(0, maxScroll),
          duration: AppConstants.animationSlow,
          curve: Curves.easeInOut,
        );
      }
    }

    // 清除滚动目标
    Future.delayed(AppConstants.animationSlow, () {
      documentProvider.clearScrollTarget();
    });
  }

  /// 构建 Markdown 内容（支持 Mermaid）
  Widget _buildMarkdownContent(
    BuildContext context,
    String content,
    String query,
    List<int> matchPositions,
    int currentMatchIndex,
    ThemeData theme,
    bool isDark,
  ) {
    // 如果没有搜索词，使用支持 Mermaid 的 Markdown 渲染
    if (query.isEmpty) {
      return _MermaidMarkdown(
        controller: _scrollController,
        content: content,
        isDark: isDark,
        theme: theme,
        onTapLink: _launchUrl,
        styleSheet: _buildMarkdownStyleSheet(theme, isDark),
      );
    }

    // 有搜索词时，使用自定义文本渲染（不支持 Mermaid）
    return SingleChildScrollView(
      controller: _scrollController,
      child: _HighlightedMarkdownContent(
        content: content,
        query: query,
        currentMatchIndex: currentMatchIndex,
        theme: theme,
        isDark: isDark,
        onTapLink: _launchUrl,
      ),
    );
  }

  /// 滚动到当前匹配位置
  void _scrollToCurrentMatch(DocumentProvider documentProvider) {
    if (!documentProvider.hasSearchResults) {
      return;
    }

    final currentIndex = documentProvider.searchResult.currentIndex;
    if (currentIndex == _lastMatchIndex) {
      return;
    }

    _lastMatchIndex = currentIndex;

    // 简单估算滚动位置（基于字符位置）
    final match = documentProvider.searchResult.currentMatch;
    if (match != null && _scrollController.hasClients) {
      final contentLength = documentProvider.content.length;
      if (contentLength > 0) {
        final scrollPercentage = match.start / contentLength;
        final maxScroll = _scrollController.position.maxScrollExtent;
        final targetScroll = maxScroll * scrollPercentage;

        _scrollController.animateTo(
          targetScroll.clamp(0, maxScroll),
          duration: AppConstants.animationNormal,
          curve: Curves.easeInOut,
        );
      }
    }
  }

  /// 构建 Markdown 样式表
  MarkdownStyleSheet _buildMarkdownStyleSheet(ThemeData theme, bool isDark) {
    final textColor = isDark ? const Color(0xFFF5F5F7) : const Color(0xFF1D1D1F);
    final codeBackgroundColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFF5F5F7);
    final blockquoteColor = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFE5E5EA);

    return MarkdownStyleSheet(
      p: TextStyle(
        fontFamily: 'PingFang SC',
        fontSize: 16,
        height: 1.75,
        color: textColor,
        letterSpacing: 0.2,
      ),
      h1: TextStyle(
        fontFamily: 'PingFang SC',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: textColor,
        letterSpacing: -0.5,
      ),
      h1Padding: const EdgeInsets.only(
        top: AppConstants.spacingLarge,
        bottom: AppConstants.spacingMedium,
      ),
      h2: TextStyle(
        fontFamily: 'PingFang SC',
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: textColor,
        letterSpacing: -0.3,
      ),
      h2Padding: const EdgeInsets.only(
        top: AppConstants.spacingLarge,
        bottom: AppConstants.spacingSmall,
      ),
      h3: TextStyle(
        fontFamily: 'PingFang SC',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: textColor,
      ),
      h3Padding: const EdgeInsets.only(
        top: AppConstants.spacingMedium,
        bottom: AppConstants.spacingSmall,
      ),
      h4: TextStyle(
        fontFamily: 'PingFang SC',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: textColor,
      ),
      h5: TextStyle(
        fontFamily: 'PingFang SC',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: textColor,
      ),
      h6: TextStyle(
        fontFamily: 'PingFang SC',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: textColor.withValues(alpha: 0.8),
      ),
      listBullet: TextStyle(
        fontSize: 16,
        color: AppTheme.primaryColor,
      ),
      listIndent: 24,
      code: TextStyle(
        fontFamily: 'SF Mono, Menlo, Monaco, Courier New, monospace',
        fontSize: 14,
        color: AppTheme.primaryColor,
        backgroundColor: codeBackgroundColor,
        letterSpacing: 0,
      ),
      codeblockDecoration: BoxDecoration(
        color: codeBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      codeblockPadding: const EdgeInsets.all(AppConstants.spacingMedium),
      blockquote: TextStyle(
        fontFamily: 'PingFang SC',
        fontSize: 16,
        fontStyle: FontStyle.italic,
        color: textColor.withValues(alpha: 0.85),
        height: 1.6,
      ),
      blockquoteDecoration: BoxDecoration(
        color: blockquoteColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border(
          left: BorderSide(
            color: AppTheme.primaryColor,
            width: 4,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMedium,
        vertical: AppConstants.spacingSmall,
      ),
      a: TextStyle(
        color: AppTheme.primaryColor,
        decoration: TextDecoration.underline,
        decorationColor: AppTheme.primaryColor.withValues(alpha: 0.4),
        decorationStyle: TextDecorationStyle.solid,
      ),
      strong: TextStyle(
        fontFamily: 'PingFang SC',
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      em: TextStyle(
        fontFamily: 'PingFang SC',
        fontStyle: FontStyle.italic,
        color: textColor,
      ),
      del: TextStyle(
        fontFamily: 'PingFang SC',
        decoration: TextDecoration.lineThrough,
        color: textColor.withValues(alpha: 0.5),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF3A3A3C)
                : const Color(0xFFE5E5EA),
            width: 1,
          ),
        ),
      ),
      tableHead: TextStyle(
        fontFamily: 'PingFang SC',
        fontWeight: FontWeight.w600,
        color: textColor,
        fontSize: 14,
      ),
      tableBody: TextStyle(
        fontFamily: 'PingFang SC',
        color: textColor,
        fontSize: 14,
      ),
      tableBorder: TableBorder.all(
        color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
        width: 1,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      tableCellsPadding: const EdgeInsets.all(AppConstants.spacingSmall + 4),
      tableHeadAlign: TextAlign.left,
      tableColumnWidth: const FlexColumnWidth(),
    );
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// 支持 Mermaid 的 Markdown 组件
class _MermaidMarkdown extends StatelessWidget {
  final ScrollController controller;
  final String content;
  final bool isDark;
  final ThemeData theme;
  final Function(String?) onTapLink;
  final MarkdownStyleSheet styleSheet;

  const _MermaidMarkdown({
    required this.controller,
    required this.content,
    required this.isDark,
    required this.theme,
    required this.onTapLink,
    required this.styleSheet,
  });

  @override
  Widget build(BuildContext context) {
    // 解析内容，提取 Mermaid 代码块
    final segments = _parseContent(content);

    return ListView.builder(
      controller: controller,
      itemCount: segments.length,
      itemBuilder: (context, index) {
        final segment = segments[index];
        
        if (segment.isMermaid) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingMedium,
            ),
            child: MermaidRenderer(
              code: segment.content,
              isDark: isDark,
            ),
          );
        }

        // 普通 Markdown 内容
        return MarkdownBody(
          data: segment.content,
          selectable: true,
          onTapLink: (text, href, title) => onTapLink(href),
          styleSheet: styleSheet,
          softLineBreak: true,
          builders: {
            'code': _CodeBlockBuilder(isDark: isDark),
          },
        );
      },
    );
  }

  /// 解析内容，分离 Mermaid 代码块和普通 Markdown
  List<_ContentSegment> _parseContent(String content) {
    final segments = <_ContentSegment>[];
    
    // 匹配代码块的正则
    final codeBlockRegex = RegExp(
      r'```(\w*)\n([\s\S]*?)```',
      multiLine: true,
    );

    int lastEnd = 0;
    
    for (final match in codeBlockRegex.allMatches(content)) {
      // 添加代码块之前的内容
      if (match.start > lastEnd) {
        final beforeContent = content.substring(lastEnd, match.start).trim();
        if (beforeContent.isNotEmpty) {
          segments.add(_ContentSegment(content: beforeContent, isMermaid: false));
        }
      }

      final language = match.group(1) ?? '';
      final code = match.group(2) ?? '';

      // 检查是否为 Mermaid 代码
      if (MermaidUtils.isMermaidCode(language, code)) {
        segments.add(_ContentSegment(content: code.trim(), isMermaid: true));
      } else {
        // 保留原始代码块
        segments.add(_ContentSegment(
          content: '```$language\n$code```',
          isMermaid: false,
        ));
      }

      lastEnd = match.end;
    }

    // 添加最后剩余的内容
    if (lastEnd < content.length) {
      final remainingContent = content.substring(lastEnd).trim();
      if (remainingContent.isNotEmpty) {
        segments.add(_ContentSegment(content: remainingContent, isMermaid: false));
      }
    }

    // 如果没有找到任何代码块，返回原始内容
    if (segments.isEmpty) {
      segments.add(_ContentSegment(content: content, isMermaid: false));
    }

    return segments;
  }
}

/// 内容片段
class _ContentSegment {
  final String content;
  final bool isMermaid;

  _ContentSegment({required this.content, required this.isMermaid});
}

/// 自定义代码块构建器
class _CodeBlockBuilder extends MarkdownElementBuilder {
  final bool isDark;

  _CodeBlockBuilder({required this.isDark});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = element.textContent;
    final language = element.attributes['class']?.replaceFirst('language-', '') ?? '';

    // 检查是否为 Mermaid（额外检查）
    if (MermaidUtils.isMermaidCode(language, code)) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingMedium,
        ),
        child: MermaidRenderer(
          code: code,
          isDark: isDark,
        ),
      );
    }

    return null; // 使用默认渲染
  }
}

/// 带高亮的 Markdown 内容组件
class _HighlightedMarkdownContent extends StatelessWidget {
  final String content;
  final String query;
  final int currentMatchIndex;
  final ThemeData theme;
  final bool isDark;
  final Function(String?) onTapLink;

  const _HighlightedMarkdownContent({
    required this.content,
    required this.query,
    required this.currentMatchIndex,
    required this.theme,
    required this.isDark,
    required this.onTapLink,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? const Color(0xFFF5F5F7) : const Color(0xFF1D1D1F);

    return SelectableText.rich(
      _buildHighlightedTextSpan(content, query, textColor),
      style: TextStyle(
        fontFamily: 'PingFang SC',
        fontSize: 16,
        height: 1.75,
        color: textColor,
        letterSpacing: 0.2,
      ),
    );
  }

  /// 构建带高亮的 TextSpan
  TextSpan _buildHighlightedTextSpan(String text, String query, Color textColor) {
    if (query.isEmpty) {
      return TextSpan(text: text);
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    
    int currentIndex = 0;
    int matchCount = 0;
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        // 添加剩余文本
        if (currentIndex < text.length) {
          spans.add(TextSpan(text: text.substring(currentIndex)));
        }
        break;
      }

      // 添加匹配前的文本
      if (index > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, index)));
      }

      // 添加高亮文本
      final isCurrentMatch = matchCount == currentMatchIndex;
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          backgroundColor: isCurrentMatch
              ? AppTheme.highlightColor
              : AppTheme.highlightColor.withValues(alpha: 0.4),
          color: const Color(0xFF1D1D1F),
          fontWeight: isCurrentMatch ? FontWeight.w600 : FontWeight.normal,
        ),
      ));

      currentIndex = index + query.length;
      start = index + 1;
      matchCount++;
    }

    return TextSpan(children: spans);
  }
}
