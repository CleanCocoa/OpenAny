import AppKit

enum OpenAnyError: Error {
    case missingFileURLOrPath
    case appNotFound(String)
}

extension OpenAnyError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingFileURLOrPath:
            return "Missing file URL or path."
        case .appNotFound(let appBundleID):
            return "App with bundle identifier \(appBundleID) not found."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .missingFileURLOrPath:
            return "Provide either\na file URL query parameter as ?url=...\n or POSIX path as ?path=..."
        case .appNotFound(_):
            return "Provide a valid bundle identifier. You can look these up in .app bundles."
        }
    }
}
