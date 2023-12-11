import AppKit

func perform(action: SmallerStringAction) throws {
    switch action.lowercased(includingObject: false).moduleSubjectVerb() {
    case (.file, "open", nil):
        guard let fileURL = action.payload?.fileURL()
        else { throw OpenAnyError.missingFileURLOrPath }
        NSWorkspace.shared.open(fileURL)

    case (.file, "reveal", nil),
         (.file, "show", nil):
        guard let fileURL = action.payload?.fileURL()
        else { throw OpenAnyError.missingFileURLOrPath }
        NSWorkspace.shared.selectFile(fileURL.absoluteURL.absoluteString, inFileViewerRootedAtPath: "")

    case (.app, let appBundleIdentifier, nil),
         (.app, let appBundleIdentifier, "launch"):
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: appBundleIdentifier)
        else { throw OpenAnyError.appNotFound(appBundleIdentifier) }
        NSWorkspace.shared.openApplication(
            at: appURL,
            configuration: .init(fromPayload: action.payload))

    case (.app, let appBundleIdentifier, "view"),
         (.file, "openwith", .some(let appBundleIdentifier)):
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: appBundleIdentifier)
        else { throw OpenAnyError.appNotFound(appBundleIdentifier) }

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
}
