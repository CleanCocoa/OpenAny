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
        do {
            try OpenAny.perform(action: action)
        } catch {
            let alert = NSAlert(error: error)
            alert.addButton(withTitle: "Quit")
            alert.runModal()
        }
        NSApp.terminate(nil)
    })

    func applicationWillFinishLaunching(_ notification: Notification) {
        urlSchemeHandler.install()
    }
}
