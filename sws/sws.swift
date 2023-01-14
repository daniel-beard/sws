import ArgumentParser
import Foundation

@main
struct SWS: AsyncParsableCommand {

    @Argument(help: "Search string")
    var searchString: String

    mutating func run() async throws {
        let start = Date().timeIntervalSince1970

        let searcher = SwiftSearcher(directory: "~/Dev/personal", searchString: searchString)
        searcher.search()

        let end = Date().timeIntervalSince1970
        let duration = (end - start) * 1000
        print("Done in: \(duration.formatted())ms")
    }
}


