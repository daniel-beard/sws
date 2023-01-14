import Foundation
import SwiftSyntax

extension SyntaxRewriter {
    func ifVisit<T: SyntaxProtocol>(_ node: T, _ matcher: Matcher?, _ filter: Filter?, _ callback: ((T) -> ())) {
        let syntax = Syntax(node)
        if (matcher?.match(syntax) ?? false) && (filter?.include(syntax) ?? true) {
            callback(node)
        }
    }
}

class ASTWalker: SyntaxRewriter {
    let fileURL: URL
    let syntax: SourceFileSyntax

    // Matchers
    let classMatcher: Matcher?
    let structMatcher: Matcher?
    let funcMatcher: Matcher?

    let filter: Filter?
    let callback: ((_ matchText: String, _ node: SyntaxProtocol) -> ())?

    init(classMatcher: Matcher? = nil,
         structMatcher: Matcher? = nil,
         funcMatcher: Matcher? = nil,
         fileURL: URL,
         syntax: SourceFileSyntax,
         filter: Filter?,
         matchingNodes: ((String, SyntaxProtocol) -> ())?) {
        self.fileURL = fileURL
        self.syntax = syntax
        self.classMatcher = classMatcher
        self.structMatcher = structMatcher
        self.funcMatcher = funcMatcher
        self.filter = filter
        self.callback = matchingNodes
    }

    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        ifVisit(node, classMatcher, filter) { node in
            callback?(node.identifier.text, node)
        }
        // never want to actually rewrite
        return super.visit(node)
    }

    override func visit(_ node: StructDeclSyntax) -> DeclSyntax {
        ifVisit(node, structMatcher, filter) { node in
            callback?(node.identifier.text, node)
        }
        // never want to actually rewrite
        return super.visit(node)
    }

    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        ifVisit(node, funcMatcher, filter) { node in
            callback?(node.identifier.text, node)
        }
        // never want to actually rewrite
        return super.visit(node)
    }
}
