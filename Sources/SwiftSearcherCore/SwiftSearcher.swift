import Foundation
import SwiftParsec
import SwiftSyntax

//MARK: Public library interface

public class SwiftSearcher {

    private var directory: String
    private var searchString: String

    public init(directory: String, searchString: String) {
        self.directory = (directory as NSString).expandingTildeInPath
        self.searchString = searchString
    }

    //TODODB: Should return source locations
    public func search() {
        // Parse input arg (search string)
        let result: MatcherParser
        do {
            result = try MatcherParser(searchString: searchString)
            print(result)
        } catch {
            print("Error parsing search string at: \(error)")
            return
        }

        // Gather files
        let sourceFiles = FileWalker.findFiles(atPath: directory, withExtension: ".swift")

        // Match & Filter!
        for sourceFile in sourceFiles {
            guard let syntax = Parser(fileURL: sourceFile).parse() else { fatalError("Parse error") }
            switch result {
                case .mFuncMatcher(let pattern, let filter):
                    let walker = FunctionWalker(fileURL: sourceFile,
                                                syntax: syntax,
                                                matcher: FunctionMatcher(pattern),
                                                filter: filter)
                    let _ = walker.visit(syntax)
                default: break
            }
        }
    }
}

//MARK: Search string parsing

func pure<A>(_ result: A) -> GenericParser<String, (), A> { GenericParser(result: result) }

enum MatcherParser {
    case mFuncMatcher(_ pattern: String?, _ filter: Filter?)
    case mStructMatcher(_ pattern: String?)
    case mClassMatcher(_ pattern: String?)
    case Error(_ message: String)

    private static let Parser: GenericParser<String, (), MatcherParser> = {
        let searchGrammar = LanguageDefinition<()>.empty
        let lexer = GenericTokenParser(languageDefinition: searchGrammar)
        let symbol = lexer.symbol
        let eof = StringParser.eof
        let char = StringParser.character

        let pattern = char(":") *> char("/") *> StringParser.anyCharacter.manyTill(char("/")).stringValue <?> "Regex pattern"

        // Filters
        let funcVisibility = (symbol("modifiers") *> pattern) >>- { p in
            pure(try! FuncModifierFilter(p))
        }

        // Matchers
        let funcMatcher = (symbol("func") *> pattern.optional) >>- { p in
            (char("|") *> funcVisibility).optional >>- { v in
                pure(Self.mFuncMatcher(p, v))
            }
        }
        let structMatcher   = Self.mStructMatcher <^> (symbol("struct") *> pattern.optional) <?> "Struct match"
        let classMatcher    = Self.mClassMatcher  <^> (symbol("class")  *> pattern.optional) <?> "Class match"

        // Everything
        return (funcMatcher <|> structMatcher <|> classMatcher) <* StringParser.eof
    }()

    init(searchString: String) throws {
        print("Arg: '\(searchString)'")
        try self = MatcherParser.Parser.run(sourceName: "", input: searchString)
    }
}


