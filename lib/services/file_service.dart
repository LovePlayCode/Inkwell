import 'dart:io';
import 'package:file_picker/file_picker.dart';

/// 文件操作服务
class FileService {
  /// 打开文件选择器，选择 .md 文件
  Future<FileResult?> pickMarkdownFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final path = file.path;

        if (path != null) {
          return await readFile(path);
        }
      }

      return null;
    } catch (e) {
      throw FileServiceException('选择文件失败: $e');
    }
  }

  /// 读取文件内容
  Future<FileResult?> readFile(String path) async {
    try {
      final file = File(path);

      if (!await file.exists()) {
        throw FileServiceException('文件不存在: $path');
      }

      final content = await file.readAsString();
      final fileName = path.split('/').last;

      return FileResult(
        path: path,
        fileName: fileName,
        content: content,
      );
    } catch (e) {
      if (e is FileServiceException) {
        rethrow;
      }
      throw FileServiceException('读取文件失败: $e');
    }
  }

  /// 检查文件是否为 Markdown 文件
  bool isMarkdownFile(String path) {
    return path.toLowerCase().endsWith('.md');
  }
}

/// 文件读取结果
class FileResult {
  final String path;
  final String fileName;
  final String content;

  FileResult({
    required this.path,
    required this.fileName,
    required this.content,
  });
}

/// 文件服务异常
class FileServiceException implements Exception {
  final String message;

  FileServiceException(this.message);

  @override
  String toString() => message;
}
