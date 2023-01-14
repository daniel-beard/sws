import Foundation
import SwiftSyntax

protocol Filter {
    func include(_ node: Syntax) -> Bool
}

struct ModifierFilter: Filter {
    let pattern: String
    let regex: Regex<Substring>
    init(_ pattern: String) throws {
        self.pattern = pattern
        regex = unwrapRegex(pattern)
    }

    func include(_ node: Syntax) -> Bool {
        if let `func` = node.as(FunctionDeclSyntax.self) {
            guard let _ = `func`.modifiersString().firstMatch(of: regex) else { return false }
            return true
        } else if let `class` = node.as(ClassDeclSyntax.self) {
            guard let _ = `class`.modifiersString().firstMatch(of: regex) else { return false }
            return true
        } else if let `struct` = node.as(StructDeclSyntax.self) {
            guard let _ = `struct`.modifiersString().firstMatch(of: regex) else { return false }
            return true
        }
        return false
    }
}
