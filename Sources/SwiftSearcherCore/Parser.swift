import Foundation
import SwiftSyntax
import SwiftSyntaxParser

struct Parser {
    let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func parse() -> SourceFileSyntax? {
        let sourceFile = try? SyntaxParser.parse(fileURL)
        return sourceFile
    }
}
