import ArgumentParser
import Foundation

@main
struct SWS: AsyncParsableCommand {

    @Argument(help: "Search string")
    var searchString: String

    mutating func run() async throws {
        let start = Date().timeIntervalSince1970

        let workingDir = FileManager.default.currentDirectoryPath
        let searcher = SwiftSearcher(directory: workingDir, searchString: searchString)
        searcher.search()

        let end = Date().timeIntervalSince1970
        let duration = (end - start) * 1000
        print("Done in: \(duration.formatted())ms")
    }
}


