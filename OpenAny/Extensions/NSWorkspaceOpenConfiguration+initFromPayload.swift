import AppKit
import URLSchemer

extension NSWorkspace.OpenConfiguration {
    convenience init(
        fromPayload payload: Payload?
    ) {
        self.init()
        self.activates = true
    }
}
