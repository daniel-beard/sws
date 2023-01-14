import Foundation
import SwiftParsec
import SwiftSyntax
import SwiftSyntaxParser

//MARK: Public library interface

public struct SearchResult {
    let location: SourceLocation
    let detail: String

    init(_ location: SourceLocation, _ detail: String) {
        self.location = location
        self.detail = detail
    }
}

public class SwiftSearcher {

    private var directory: String
    private var searchString: String
    private let resultSyncQueue = DispatchQueue(label: "sync.dict.queue")
    private var searchResults = [URL: [SearchResult]]()

    public init(directory: String, searchString: String) {
        self.directory = (directory as NSString).expandingTildeInPath
        self.searchString = searchString
    }

    public func search() {
        // Parse input arg (search string)
        let parsedArg: MatcherParser
        do {
            parsedArg = try MatcherParser(searchString: searchString)
        } catch {
            print("Error parsing search string at: \(error)")
            return
        }

        // Gather files
        let sourceFiles = FileWalker.findFiles(atPath: directory, withExtension: ".swift")
        print("Searching \(sourceFiles.count) files")

        let reporter = RelativePathReporter()
        let directory = self.directory

        // Match & Filter!
        let operationQueue = OperationQueue()
        for sourceFile in sourceFiles {
            operationQueue.addOperation(BlockOperation(block: {
                let result = Self.search(sourceFile: sourceFile, inDirectory: directory, args: parsedArg, reporter: reporter)
                self.resultSyncQueue.async {
                    self.searchResults[sourceFile] = result

                    for searchResult in result {
                        print(reporter.report(searchResult, directory: directory))
                    }
                }
            }))
        }
        operationQueue.waitUntilAllOperationsAreFinished()
    }

    // Search a single file and return source locations.
    class func search(sourceFile: URL, inDirectory directory: String, args: MatcherParser, reporter: Reporter) -> [SearchResult] {
        var result = [SearchResult]()
        do {
            let syntax = try SyntaxParser.parse(sourceFile)
            let walker: ASTWalker!
            let onMatch: (String, SyntaxProtocol) -> () = { detail, node in
                let location = sourceLocation(forNode: node, filePath: sourceFile.relativePath, tree: syntax)
                result.append(SearchResult(location, detail))
            }
            switch args {
                case .mFuncMatcher(let pattern, let filter):
                    walker = ASTWalker(funcMatcher: FunctionMatcher(pattern), fileURL: sourceFile, syntax: syntax, filter: filter, matchingNodes: onMatch)
                case .mStructMatcher(let pattern, let filter):
                    walker = ASTWalker(structMatcher: StructMatcher(pattern), fileURL: sourceFile, syntax: syntax, filter: filter, matchingNodes: onMatch)
                case .mClassMatcher(let pattern, let filter):
                    walker = ASTWalker(classMatcher: ClassMatcher(pattern), fileURL: sourceFile, syntax: syntax, filter: filter, matchingNodes: onMatch)
                default: fatalError("Not implemented")
            }
            let _ = walker.visit(syntax)
        } catch {
            fatalError("Error: '\(error)' when parsing source file: \(sourceFile)")
        }
        return result
    }
}

//MARK: Search string parsing

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

func pure<A>(_ result: A) -> GenericParser<String, (), A> { GenericParser(result: result) }

enum MatcherParser {
    case mFuncMatcher(_ pattern: String?, _ filter: Filter?)
    case mStructMatcher(_ pattern: String?, _ filter: Filter?)
    case mClassMatcher(_ pattern: String?, _ filter: Filter?)
    case Error(_ message: String)

    private static let Parser: GenericParser<String, (), MatcherParser> = {
        let searchGrammar = LanguageDefinition<()>.empty
        let lexer = GenericTokenParser(languageDefinition: searchGrammar)
        let symbol = lexer.symbol
        let eof = StringParser.eof
        let char = StringParser.character

        let pattern = char(":") *> char("/") *> StringParser.anyCharacter.manyTill(char("/")).stringValue <?> "Regex pattern"

        // Filters
        let modifierFilter = (symbol("modifiers") *> pattern) >>- { p in
            pure(try! ModifierFilter(p))
        }

        // Matchers
        let funcMatcher = (symbol("func") *> pattern.optional) >>- { p in
            (char("|") *> modifierFilter).optional >>- { v in
                pure(Self.mFuncMatcher(p, v))
            } <?> "Filter"
        } <?> "Func matcher"
        let classMatcher    = (symbol("class")  *> pattern.optional) >>- { p in
            (char("|") *> modifierFilter).optional >>- { v in
                pure(Self.mClassMatcher(p, v))
            } <?> "Filter"
        } <?> "Class match"
        let structMatcher   = (symbol("struct") *> pattern.optional) >>- { p in
            (char("|") *> modifierFilter).optional >>- { v in
                pure(Self.mStructMatcher(p, v))
            } <?> "Filter"
        } <?> "Struct match"

        // Everything
        return (funcMatcher <|> structMatcher <|> classMatcher) <* StringParser.eof
    }()

    init(searchString: String) throws {
        print("Arg: '\(searchString)'")
        try self = MatcherParser.Parser.run(sourceName: "", input: searchString)
    }
}


