/// 搜索匹配结果
class SearchMatch {
  final int start;
  final int end;
  final String text;

  SearchMatch({
    required this.start,
    required this.end,
    required this.text,
  });
}

/// 搜索结果
class SearchResult {
  final String query;
  final List<SearchMatch> matches;
  final int currentIndex;

  SearchResult({
    required this.query,
    required this.matches,
    this.currentIndex = 0,
  });

  /// 是否有匹配结果
  bool get hasMatches => matches.isNotEmpty;

  /// 匹配总数
  int get totalMatches => matches.length;

  /// 当前匹配项（从1开始）
  int get currentMatchNumber => hasMatches ? currentIndex + 1 : 0;

  /// 当前匹配
  SearchMatch? get currentMatch {
    if (!hasMatches || currentIndex < 0 || currentIndex >= matches.length) {
      return null;
    }
    return matches[currentIndex];
  }

  /// 创建新的搜索结果，更新当前索引
  SearchResult copyWith({int? currentIndex}) {
    return SearchResult(
      query: query,
      matches: matches,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  /// 空结果
  static SearchResult empty() {
    return SearchResult(
      query: '',
      matches: [],
      currentIndex: 0,
    );
  }
}
