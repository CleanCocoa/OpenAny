import AppKit

/// Tries to interpret `bundleIdentifierOrName` as a bundle ID first. Upon failure, searches application directories.
func appURL(
    bundleIdentifierOrName: String
) throws -> URL? {
    return try NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifierOrName)
            ?? appURL(forAppNamed: bundleIdentifierOrName)
}

fileprivate func appURL(
    forAppNamed name: String
) throws -> URL? {
    let name = name.lowercased()

    // TODO: Are there other places we should add? Contains (as of 2023-12-13):
    //   - ~/Applications/
    //   - /Applications/
    //   - /Network/Applications/
    //   - /System/Cryptexes/App/System/Applications/
    //   - /System/Cryptexes/OS/System/Applications/
    //   - /System/Applications/
    let searchPaths: [URL] = FileManager.default.urls(for: .applicationDirectory, in: .allDomainsMask)
        .filter(FileManager.default.directoryExists(at:))

    // We're collecting all candidates without quickly exiting because (1) we can offer a user interactive selection, if needed, and (2) the performance penalty of searching in the 100's of URL's is negligible.
    let searchPathContents = try searchPaths.flatMap { directoryURL in
        try FileManager.default
            .contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
    }
    let candidates = searchPathContents.filter { fileURL in
        fileURL.pathExtension.lowercased() == "app"
            && fileURL.lastPathComponent.lowercased().contains(name)
    }
    return candidates.first
}

