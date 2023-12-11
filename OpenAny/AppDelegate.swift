import Cocoa
import URLSchemer

extension Module {
    static var app = Module("app")
    static var file = Module("file")
}

extension NSWorkspace.OpenConfiguration {
    convenience init(
        fromPayload payload: Payload?
    ) {
        self.init()
        self.activates = true
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        URLSchemeHandler(actionHandler: { action in
            switch action.lowercased(includingObject: false).moduleSubjectVerbObject() {
            case (.file, "open", _, _):
                guard let payload = action.payload else {
                    return
                }

                if let fileURL = payload["url"]?.flatMap(URL.init(string:)) {
                    NSWorkspace.shared.open(fileURL)
                } else if let maybePath = payload["path"],
                          let path = maybePath {
                    let fileURL = URL(fileURLWithPath: path)
                    NSWorkspace.shared.open(fileURL)
                }

            case (.app, let appBundleIdentifier, "launch", _):
                guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: appBundleIdentifier)
                else { return }
                NSWorkspace.shared.openApplication(
                    at: appURL,
                    configuration: .init(fromPayload: action.payload))

            default: return
            }
        }).install()
    }
}
