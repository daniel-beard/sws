import Foundation
import SwiftSyntax

protocol Reporter {
    func report(_ searchResult: SearchResult, directory: String) -> String
}

struct RelativePathReporter: Reporter {
    func report(_ searchResult: SearchResult, directory: String) -> String {
        let loc = searchResult.location
        let relativePath = ".\(loc.file?.deletingPrefix(directory) ?? "UNKNOWN")"
        let line = loc.line ?? 0
        let column = loc.column ?? 0
        return "\(relativePath) \(line):\(column)"
    }
}
