import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel?
  private var pendingFiles: [String] = []
  private var isFlutterReady = false
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  override func applicationWillFinishLaunching(_ notification: Notification) {
    NSLog("[Inkwell] applicationWillFinishLaunching")
  }
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    NSLog("[Inkwell] applicationDidFinishLaunching - pending files: \(pendingFiles.count)")
  }
  
  /// 当 FlutterViewController 准备就绪时由 MainFlutterWindow 调用
  func onFlutterViewControllerReady(_ controller: FlutterViewController) {
    NSLog("[Inkwell] onFlutterViewControllerReady called")
    
    methodChannel = FlutterMethodChannel(
      name: "com.inkwell/file_handler",
      binaryMessenger: controller.engine.binaryMessenger
    )
    
    isFlutterReady = true
    NSLog("[Inkwell] Method channel ready! Pending files: \(pendingFiles.count)")
    
    // 处理所有待处理的文件
    processPendingFiles()
  }
  
  private func processPendingFiles() {
    guard !pendingFiles.isEmpty else { return }
    
    // 给 Flutter UI 一点时间完成初始化
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      NSLog("[Inkwell] Now processing \(self.pendingFiles.count) pending files")
      for filePath in self.pendingFiles {
        NSLog("[Inkwell] Sending pending file to Flutter: \(filePath)")
        self.methodChannel?.invokeMethod("openFile", arguments: filePath)
      }
      self.pendingFiles.removeAll()
    }
  }
  
  // 处理通过双击文件打开应用的情况（单个文件）
  override func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    NSLog("[Inkwell] openFile called: \(filename)")
    handleOpenFile(filename)
    return true
  }
  
  // 处理通过拖拽或其他方式打开多个文件的情况
  override func application(_ sender: NSApplication, openFiles filenames: [String]) {
    NSLog("[Inkwell] openFiles called: \(filenames.count) files - \(filenames)")
    for filename in filenames {
      handleOpenFile(filename)
    }
    NSApp.reply(toOpenOrPrint: .success)
  }
  
  // 处理 URL 方式打开文件 - macOS 13+ 推荐使用此方法
  override func application(_ application: NSApplication, open urls: [URL]) {
    NSLog("[Inkwell] application:open:urls called: \(urls.count) urls")
    for url in urls {
      NSLog("[Inkwell] URL: \(url)")
      if url.isFileURL {
        handleOpenFile(url.path)
      }
    }
  }
  
  private func handleOpenFile(_ filename: String) {
    let fileUrl = URL(fileURLWithPath: filename).absoluteString
    NSLog("[Inkwell] handleOpenFile: \(fileUrl), ready: \(isFlutterReady), channel: \(methodChannel != nil)")
    
    if isFlutterReady, let channel = methodChannel {
      NSLog("[Inkwell] Sending file to Flutter immediately")
      channel.invokeMethod("openFile", arguments: fileUrl)
    } else {
      NSLog("[Inkwell] Queueing file for later, current queue size: \(pendingFiles.count)")
      pendingFiles.append(fileUrl)
    }
  }
}
