import Foundation
import SwiftSyntax

public extension SyntaxProtocol {

    /// If this node is contained in a function, return the function name, otherwise nil.
    func enclosingFunctionName() -> String? {
        var currParent: Syntax? = self.parent
        while currParent != nil {
            if currParent?.is(FunctionDeclSyntax.self) ?? false {
                return currParent?.as(FunctionDeclSyntax.self)?.identifier.text
            }
            currParent = currParent?.parent
        }
        return nil
    }

    func enclosingStructName() -> String? {
        var currParent: Syntax? = self.parent
        while currParent != nil {
            if currParent?.is(StructDeclSyntax.self) ?? false {
                return currParent?.as(StructDeclSyntax.self)?.identifier.text
            }
            currParent = currParent?.parent
        }
        return nil
    }

    /// If this node is enclosed in a class, return the class name, otherwise nil.
    func enclosingClassName() -> String? {
        var currParent: Syntax? = self.parent
        while currParent != nil {
            if currParent?.is(ClassDeclSyntax.self) ?? false {
                return currParent?.as(ClassDeclSyntax.self)?.identifier.text
            }
            currParent = currParent?.parent
        }
        return nil
    }

    func enclosingExtensionName() -> String? {
        var currParent: Syntax? = self.parent
        while currParent != nil {
            if currParent?.is(ExtensionDeclSyntax.self) ?? false {
                guard let nameText = currParent?.as(ExtensionDeclSyntax.self)?
                    .extendedType.as(SimpleTypeIdentifierSyntax.self)?
                    .name.text else { continue }
                return nameText
            }
            currParent = currParent?.parent
        }
        return nil
    }

    func nameOfContainer() -> String? {
        if let `extension` = Syntax(self).as(ExtensionDeclSyntax.self) {
            return `extension`.extendedType.as(SimpleTypeIdentifierSyntax.self)?.name.text
        }
        if let `class` = Syntax(self).as(ClassDeclSyntax.self) {
            return `class`.identifier.text
        }
        if let `struct` = Syntax(self).as(StructDeclSyntax.self) {
            return `struct`.identifier.text
        }
        if let `enum` = Syntax(self).as(EnumDeclSyntax.self) {
            return `enum`.identifier.text
        }
        if let `protocol` = Syntax(self).as(ProtocolDeclSyntax.self) {
            return `protocol`.identifier.text
        }
        return nil
    }

    func allParents() -> [Syntax] {
        var currParent: Syntax? = self.parent
        var parents = [Syntax]()
        while currParent != nil {
            parents.append(currParent!)
            currParent = currParent?.parent
        }
        return parents
    }
}

extension FunctionDeclSyntax {
    func modifiersString() -> String {
        modifiers?.map({ (attr) in
            attr.tokens.map({ $0.text }).joined(separator: "")
        }).joined(separator: " ") ?? ""
    }
}
