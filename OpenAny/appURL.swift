import AppKit

/// Tries to interpret `bundleIdentifierOrName` as a bundle ID first. Upon failure, searches application directories.
func appURL(
    bundleIdentifierOrName: String
) -> URL? {
    return  NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifierOrName)
        ?? (try? appURL(forAppNamed: bundleIdentifierOrName))
}

fileprivate func appURL(
    forAppNamed name: String
) throws -> URL? {
    let name = name.lowercased()

    // TODO: Are there other places we should add? Reports (as of 2023-12-13):
    //   - ~/Applications/
    //   - /Applications/
    //   - /Network/Applications/
    //   - /System/Cryptexes/App/System/Applications/
    //   - /System/Cryptexes/OS/System/Applications/
    //   - /System/Applications/
    let searchURLs: [URL] = FileManager.default.urls(for: .applicationDirectory, in: .allDomainsMask)

    // We're collecting all candidates without quickly exiting because (1) we can offer a user interactive selection, if needed, and (2) the performance penalty of searching in the 100's of URL's is negligible.
    let candidates = try searchURLs.flatMap { directoryURL in
        try FileManager.default
            .contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
            .filter { fileURL in
                fileURL.pathExtension.lowercased() == ".app"
                    && fileURL.lastPathComponent.lowercased().contains(name)
            }
    }
    return candidates.first
}

