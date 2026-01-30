/// Markdown 标题模型
class Heading {
  final int level; // 1-6 对应 h1-h6
  final String text;
  final int lineIndex; // 在原文中的行号
  final int charIndex; // 在原文中的字符位置

  const Heading({
    required this.level,
    required this.text,
    required this.lineIndex,
    required this.charIndex,
  });

  @override
  String toString() {
    return 'Heading(level: $level, text: $text, line: $lineIndex)';
  }
}

/// 标题解析服务
class HeadingParser {
  /// 从 Markdown 内容中解析标题
  static List<Heading> parse(String content) {
    final headings = <Heading>[];
    final lines = content.split('\n');
    int charIndex = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final heading = _parseLine(line, i, charIndex);
      if (heading != null) {
        headings.add(heading);
      }
      charIndex += line.length + 1; // +1 for newline
    }

    return headings;
  }

  /// 解析单行，检测是否为标题
  static Heading? _parseLine(String line, int lineIndex, int charIndex) {
    final trimmed = line.trim();
    
    // 检测 ATX 风格标题 (# heading)
    if (trimmed.startsWith('#')) {
      int level = 0;
      for (int i = 0; i < trimmed.length && trimmed[i] == '#'; i++) {
        level++;
      }
      
      // 最多支持 6 级标题
      if (level >= 1 && level <= 6 && trimmed.length > level) {
        // 确保 # 后面有空格
        if (trimmed[level] == ' ') {
          final text = trimmed.substring(level + 1).trim();
          // 移除尾部的 # 号（如果有）
          final cleanText = _removeTrailingHashes(text);
          if (cleanText.isNotEmpty) {
            return Heading(
              level: level,
              text: cleanText,
              lineIndex: lineIndex,
              charIndex: charIndex,
            );
          }
        }
      }
    }

    return null;
  }

  /// 移除尾部的 # 号
  static String _removeTrailingHashes(String text) {
    var result = text;
    while (result.endsWith('#')) {
      result = result.substring(0, result.length - 1).trim();
    }
    return result;
  }
}
