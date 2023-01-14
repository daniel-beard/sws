import Foundation
import SwiftSyntax

protocol Matcher {
    func match(_ node: Syntax) -> Bool
}

func unwrapRegex(_ pattern: String) -> Regex<Substring> {
    do {
        return try Regex(pattern, as: Substring.self)
    } catch {
        fatalError("Bad regex pattern: \(pattern)")
    }
}

struct FunctionMatcher: Matcher {
    let pattern: String?
    let regex: Regex<Substring>
    init(_ pattern: String?) {
        self.pattern = pattern
        regex = unwrapRegex(pattern ?? ".*")
    }

    func match(_ node: Syntax) -> Bool {
        guard let `func` = node.as(FunctionDeclSyntax.self) else { return false }
        guard let _ = `func`.identifier.text.firstMatch(of: regex) else { return false }
        return true
    }
}

struct ClassMatcher: Matcher {
    let pattern: String?
    let regex: Regex<Substring>
    init(_ pattern: String?) {
        self.pattern = pattern
        regex = unwrapRegex(pattern ?? ".*")
    }

    func match(_ node: Syntax) -> Bool {
        guard let `class` = node.as(ClassDeclSyntax.self) else { return false }
        guard let _ = `class`.identifier.text.firstMatch(of: regex) else { return false }
        return true
    }
}

struct StructMatcher: Matcher {
    let pattern: String?
    let regex: Regex<Substring>
    init(_ pattern: String?) {
        self.pattern = pattern
        regex = unwrapRegex(pattern ?? ".*")
    }

    func match(_ node: Syntax) -> Bool {
        guard let `struct` = node.as(StructDeclSyntax.self) else { return false }
        guard let _ = `struct`.identifier.text.firstMatch(of: regex) else { return false }
        return true
    }
}
