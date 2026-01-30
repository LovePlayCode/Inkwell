import 'package:flutter/material.dart';
import '../models/search_result.dart';
import '../models/heading.dart';
import '../services/file_service.dart';
import '../services/search_service.dart';

/// 文档状态管理
class DocumentProvider extends ChangeNotifier {
  final FileService _fileService = FileService();
  final SearchService _searchService = SearchService();

  // 文档状态
  String? _filePath;
  String? _fileName;
  String _content = '';
  bool _isLoading = false;
  String? _error;

  // 搜索状态
  bool _isSearchVisible = false;
  String _searchQuery = '';
  SearchResult _searchResult = SearchResult.empty();

  // 大纲滚动状态
  Heading? _targetHeading;
  int? _activeHeadingIndex;

  // Getters - 文档
  String? get filePath => _filePath;
  String? get fileName => _fileName;
  String get content => _content;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasDocument => _content.isNotEmpty;

  // Getters - 搜索
  bool get isSearchVisible => _isSearchVisible;
  String get searchQuery => _searchQuery;
  SearchResult get searchResult => _searchResult;
  bool get hasSearchResults => _searchResult.hasMatches;
  int get currentMatchIndex => _searchResult.currentIndex;

  // Getters - 大纲
  Heading? get targetHeading => _targetHeading;
  int? get activeHeadingIndex => _activeHeadingIndex;

  /// 打开文件选择器
  Future<void> openFile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _fileService.pickMarkdownFile();
      if (result != null) {
        _filePath = result.path;
        _fileName = result.fileName;
        _content = result.content;
        _clearSearch();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 从路径加载文件
  Future<void> loadFile(String path) async {
    if (!_fileService.isMarkdownFile(path)) {
      _error = '请选择 .md 文件';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _fileService.readFile(path);
      if (result != null) {
        _filePath = result.path;
        _fileName = result.fileName;
        _content = result.content;
        _clearSearch();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 显示搜索栏
  void showSearch() {
    _isSearchVisible = true;
    notifyListeners();
  }

  /// 隐藏搜索栏
  void hideSearch() {
    _isSearchVisible = false;
    _clearSearch();
    notifyListeners();
  }

  /// 切换搜索栏显示状态
  void toggleSearch() {
    if (_isSearchVisible) {
      hideSearch();
    } else {
      showSearch();
    }
  }

  /// 执行搜索
  void search(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _searchResult = SearchResult.empty();
    } else {
      _searchResult = _searchService.search(_content, query);
    }

    notifyListeners();
  }

  /// 跳转到下一个匹配项
  void nextMatch() {
    if (!_searchResult.hasMatches) {
      return;
    }

    int newIndex = _searchResult.currentIndex + 1;
    if (newIndex >= _searchResult.totalMatches) {
      newIndex = 0;
    }

    _searchResult = _searchResult.copyWith(currentIndex: newIndex);
    notifyListeners();
  }

  /// 跳转到上一个匹配项
  void previousMatch() {
    if (!_searchResult.hasMatches) {
      return;
    }

    int newIndex = _searchResult.currentIndex - 1;
    if (newIndex < 0) {
      newIndex = _searchResult.totalMatches - 1;
    }

    _searchResult = _searchResult.copyWith(currentIndex: newIndex);
    notifyListeners();
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 清除搜索
  void _clearSearch() {
    _searchQuery = '';
    _searchResult = SearchResult.empty();
  }

  /// 滚动到指定标题
  void scrollToHeading(Heading heading) {
    final headings = HeadingParser.parse(_content);
    _activeHeadingIndex = headings.indexOf(heading);
    _targetHeading = heading;
    notifyListeners();
  }

  /// 清除滚动目标
  void clearScrollTarget() {
    _targetHeading = null;
    notifyListeners();
  }

  /// 更新当前活跃标题索引
  void updateActiveHeadingIndex(int? index) {
    if (_activeHeadingIndex != index) {
      _activeHeadingIndex = index;
      notifyListeners();
    }
  }
}
