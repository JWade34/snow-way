import UIKit
import Capacitor

// The app's main screen: Capacitor's web view showing snowway.app, plus the app's own native plugin.
class SnowWayViewController: CAPBridgeViewController {
    private static var pendingPath: String?

    override open func capacitorDidLoad() {
        bridge?.registerPluginInstance(SnowWayPlugin())
        NotificationCenter.default.addObserver(forName: .snowWayOpenPath, object: nil, queue: .main) { [weak self] note in
            if let path = note.object as? String { self?.load(path: path) }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let path = Self.pendingPath { Self.pendingPath = nil; load(path: path) }
    }

    // Opens a snowway.app page (from Siri, Spotlight or a widget tap). Waits for the web view on a cold start.
    static func open(path: String) {
        guard path.hasPrefix("/") else { return }
        if let vc = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController as? SnowWayViewController }).first,
           vc.isViewLoaded, vc.view.window != nil {
            vc.load(path: path)
        } else if let vc = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController as? SnowWayViewController, vc.view.window != nil {
            vc.load(path: path)
        } else {
            pendingPath = path
        }
    }

    private func load(path: String) {
        webView?.load(URLRequest(url: SnowWayAPI.pageURL(path)))
    }
}

extension Notification.Name {
    static let snowWayOpenPath = Notification.Name("snowWayOpenPath")
}
