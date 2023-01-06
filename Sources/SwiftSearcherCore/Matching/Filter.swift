import Foundation
import SwiftSyntax

protocol Filter {
    func include(_ node: Syntax) -> Bool
}

struct FuncModifierFilter: Filter {
    let pattern: String
    let regex: Regex<Substring>
    init(_ pattern: String) throws {
        self.pattern = pattern
        regex = unwrapRegex(pattern)
    }

    func include(_ node: Syntax) -> Bool {
        guard let `func` = node.as(FunctionDeclSyntax.self) else { return false }
        guard let _ = `func`.modifiersString().firstMatch(of: regex) else { return false }
        return true
    }
}
