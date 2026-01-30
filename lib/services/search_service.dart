import '../models/search_result.dart';

/// 搜索服务
class SearchService {
  /// 在文本中搜索关键词
  SearchResult search(String content, String query) {
    if (query.isEmpty || content.isEmpty) {
      return SearchResult.empty();
    }

    final matches = <SearchMatch>[];
    final lowerContent = content.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    while (true) {
      final index = lowerContent.indexOf(lowerQuery, start);
      if (index == -1) {
        break;
      }

      matches.add(SearchMatch(
        start: index,
        end: index + query.length,
        text: content.substring(index, index + query.length),
      ));

      start = index + 1;
    }

    return SearchResult(
      query: query,
      matches: matches,
      currentIndex: 0,
    );
  }

  /// 获取匹配位置对应的行号
  int getLineNumber(String content, int position) {
    if (position < 0 || position > content.length) {
      return -1;
    }

    int lineNumber = 1;
    for (int i = 0; i < position && i < content.length; i++) {
      if (content[i] == '\n') {
        lineNumber++;
      }
    }

    return lineNumber;
  }

  /// 获取包含位置的行内容
  String getLineContent(String content, int position) {
    if (position < 0 || position > content.length) {
      return '';
    }

    // 找到行的开始
    int lineStart = position;
    while (lineStart > 0 && content[lineStart - 1] != '\n') {
      lineStart--;
    }

    // 找到行的结束
    int lineEnd = position;
    while (lineEnd < content.length && content[lineEnd] != '\n') {
      lineEnd++;
    }

    return content.substring(lineStart, lineEnd);
  }
}
