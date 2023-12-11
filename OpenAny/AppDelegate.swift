import Cocoa
import URLSchemer

extension Module {
    static var app = Module("app")
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
