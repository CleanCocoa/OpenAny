import Foundation

extension FileManager {
    func directoryExists(at url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = self.fileExists(atPath: url.standardizedFileURL.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}
