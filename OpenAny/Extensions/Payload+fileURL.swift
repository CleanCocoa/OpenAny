import Foundation
import URLSchemer

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
