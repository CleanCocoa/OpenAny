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

extension Payload {
    func fileURL() -> URL? {
        if let fileURL = self["url"]?.flatMap(URL.init(string:)) {
            return fileURL
        } else if let maybePath = self["path"],
                  let path = maybePath {
            return URL(fileURLWithPath: path)
        }
        return nil
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var window: NSWindow!

    lazy var urlSchemeHandler = URLSchemeHandler(actionHandler: { action in
        switch action.lowercased(includingObject: false).moduleSubjectVerb() {
        case (.file, "open", nil):
            guard let fileURL = action.payload?.fileURL() else { return }

            NSWorkspace.shared.open(fileURL)

        case (.app, let appBundleIdentifier, nil):
            guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: appBundleIdentifier)
            else { return }
            NSWorkspace.shared.openApplication(
                at: appURL,
                configuration: .init(fromPayload: action.payload))

        case (.app, let appBundleIdentifier, "view"):
            guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: appBundleIdentifier)
            else { return }

            if let fileURL = action.payload?.fileURL() {
                NSWorkspace.shared.open(
                    [fileURL],
                    withApplicationAt: appURL,
                    configuration: .init(fromPayload: action.payload))
            } else {
                NSWorkspace.shared.openApplication(
                    at: appURL,
                    configuration: .init(fromPayload: action.payload))
            }

        default: return
        }
    })

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        urlSchemeHandler.install()
    }
}
