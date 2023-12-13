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

    case (.app, let appBundleIdentifierOrName, nil),
         (.app, let appBundleIdentifierOrName, "launch"):
        guard let appURL = try appURL(bundleIdentifierOrName: appBundleIdentifierOrName)
        else { throw OpenAnyError.appNotFound(appBundleIdentifierOrName) }
        NSWorkspace.shared.openApplication(
            at: appURL,
            configuration: .init(fromPayload: action.payload))

    case (.app, let appBundleIdentifierOrName, "view"),
         (.file, "openwith", .some(let appBundleIdentifierOrName)):
        guard let appURL = try appURL(bundleIdentifierOrName: appBundleIdentifierOrName)
        else { throw OpenAnyError.appNotFound(appBundleIdentifierOrName) }

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
