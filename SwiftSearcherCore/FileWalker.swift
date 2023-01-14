import Foundation

struct FileWalker {

    static func findFiles(atPath path: String, withExtension fileExtension: String) -> [URL] {
        let folderURL = URL(fileURLWithPath: (path as NSString).expandingTildeInPath)
        var result = [URL]()
        do {
            let resourceKeys: [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
            let enumerator = FileManager.default.enumerator(at: folderURL,
                                                            includingPropertiesForKeys: resourceKeys,
                                                            options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                print("FileWalker error at \(url): ", error)
                return true
            })!

            for case let fileURL as URL in enumerator {
                let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                guard resourceValues.isDirectory! == false, fileURL.absoluteString.hasSuffix(fileExtension) else {
                    continue
                }
                result.append(fileURL)
            }
        } catch {
            print(error)
        }
        return result
    }
}
