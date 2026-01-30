import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // 设置窗口最小尺寸
    self.minSize = NSSize(width: 800, height: 600)
    
    // 设置窗口标题栏样式
    self.titlebarAppearsTransparent = false
    self.titleVisibility = .visible
    self.title = "Inkwell"

    RegisterGeneratedPlugins(registry: flutterViewController)
    
    // 通知 AppDelegate FlutterViewController 已就绪
    if let appDelegate = NSApp.delegate as? AppDelegate {
      appDelegate.onFlutterViewControllerReady(flutterViewController)
    }

    super.awakeFromNib()
  }
}
