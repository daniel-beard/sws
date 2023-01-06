import Foundation
import SwiftSyntax

class FunctionWalker: SyntaxRewriter {
    let fileURL: URL
    let syntax: SourceFileSyntax
    let matcher: FunctionMatcher
    let filter: Filter?

    init(fileURL: URL, syntax: SourceFileSyntax, matcher: FunctionMatcher, filter: Filter?) {
        self.fileURL = fileURL
        self.syntax = syntax
        self.matcher = matcher
        self.filter = filter
    }

    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        if matcher.match(Syntax(node)) && (filter?.include(Syntax(node)) ?? true) {
            print("Found matching func: \(node.identifier.text): \(node.allParents().map { $0.nameOfContainer() })")
        }
        // never want to actually rewrite
        return super.visit(node)
    }
}
