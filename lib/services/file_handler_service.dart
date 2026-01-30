import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 文件处理服务
/// 用于接收系统传入的文件打开事件
class FileHandlerService {
  static const MethodChannel _channel = MethodChannel('com.inkwell/file_handler');
  
  static final StreamController<String> _fileOpenController = StreamController<String>.broadcast();
  
  /// 缓存在订阅之前接收到的文件路径
  static final List<String> _pendingFiles = [];
  
  /// 是否有订阅者
  static bool _hasSubscribers = false;
  
  /// 文件打开事件流（带有缓冲功能）
  static Stream<String> get onFileOpen {
    return _fileOpenController.stream;
  }
  
  /// 初始化服务
  static void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
    debugPrint('[FileHandlerService] Initialized');
  }
  
  /// 注册订阅者并获取待处理的文件
  /// 在 UI 准备好后调用此方法来获取可能在启动时接收到的文件
  static StreamSubscription<String> subscribe(void Function(String) onData) {
    _hasSubscribers = true;
    
    // 处理所有待处理的文件
    if (_pendingFiles.isNotEmpty) {
      debugPrint('[FileHandlerService] Processing ${_pendingFiles.length} pending files');
      // 使用 Future.microtask 确保在当前帧结束后处理
      Future.microtask(() {
        for (final filePath in _pendingFiles) {
          debugPrint('[FileHandlerService] Sending pending file: $filePath');
          onData(filePath);
        }
        _pendingFiles.clear();
      });
    }
    
    return _fileOpenController.stream.listen(onData);
  }
  
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    debugPrint('[FileHandlerService] Received method call: ${call.method}');
    debugPrint('[FileHandlerService] Arguments: ${call.arguments}');
    
    switch (call.method) {
      case 'openFile':
        final String fileUrl = call.arguments as String;
        // 将 file:// URL 转换为路径
        String filePath = fileUrl;
        if (fileUrl.startsWith('file://')) {
          filePath = Uri.decodeComponent(fileUrl.substring(7));
        }
        debugPrint('[FileHandlerService] Opening file: $filePath');
        
        // 如果还没有订阅者，先缓存文件路径
        if (!_hasSubscribers) {
          debugPrint('[FileHandlerService] No subscribers yet, queueing file');
          _pendingFiles.add(filePath);
        } else {
          _fileOpenController.add(filePath);
        }
        return null;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'Method ${call.method} not implemented',
        );
    }
  }
  
  /// 释放资源
  static void dispose() {
    _fileOpenController.close();
    _pendingFiles.clear();
    _hasSubscribers = false;
  }
}
