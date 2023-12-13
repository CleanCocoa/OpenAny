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
                  let path = (maybePath as NSString?)?.expandingTildeInPath {
            return URL(fileURLWithPath: path)
        }
        return nil
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var window: NSWindow!

    lazy var urlSchemeHandler = URLSchemeHandler(actionHandler: { action in
        Task { @MainActor in
            do {
                try await OpenAny.perform(action: action)
            } catch {
                let alert = NSAlert(error: error)
                alert.addButton(withTitle: "Quit")
                alert.runModal()
            }
            NSApp.terminate(nil)
        }
    })

    func applicationWillFinishLaunching(_ notification: Notification) {
        urlSchemeHandler.install()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        let bundleIdentifiers = urls.compactMap { Bundle(url: $0)?.bundleIdentifier }

        let alert = NSAlert()
        alert.messageText = "Bundle Identifiers"
        alert.informativeText = "Here are the app bundle identifiers of the files you selected so you can use them for openany://app/ and similar:"
        alert.accessoryView = scrollableTextView(content: bundleIdentifiers.joined(separator: "\n"))
        alert.runModal()
    }

    private func scrollableTextView(
        content: String
    ) -> NSScrollView {
        let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 400, height: 150))
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = NSBorderType.bezelBorder
        scrollView.autoresizingMask = [ .width, .height ]

        let contentSize = scrollView.contentSize
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height))
        textView.isVerticallyResizable = true
        textView.isEditable = true
        textView.textContainer?.containerSize = NSSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.string = content
        scrollView.documentView = textView

        return scrollView
    }
}
