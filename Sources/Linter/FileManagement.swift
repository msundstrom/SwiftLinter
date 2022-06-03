import Foundation

extension URL {
    func matches(_ fileTypes: [FileType]) -> FileType? {
        for fileType in fileTypes {
            if fileType.matches(self) {
                return fileType
            }
        }

        return nil
    }
}

public protocol LintFileManager {
    func preloadFiles(ofTypes types: [FileType], baseURL: URL, ignoreList: [FileIgnore])
    func files(ofType type: FileType, ignoreList: [FileIgnore]) -> [URL]

}

struct FileUtility {
    static func readLines(forFile fileURL: URL, stopOnFailure: Bool = false, _ byLine: (_ line: String, _ lineNr: Int) -> Bool) {
        guard let filePointer:UnsafeMutablePointer<FILE> = fopen(fileURL.path,"r") else {
            preconditionFailure("Could not open file at \(fileURL.absoluteString)")
        }

        var lineByteArrayPointer: UnsafeMutablePointer<CChar>? = nil

        defer {
            fclose(filePointer)
            lineByteArrayPointer?.deallocate()
        }

        var lineCap: Int = 0
        var bytesRead = getline(&lineByteArrayPointer, &lineCap, filePointer)

        var lineCounter = 1
        while (bytesRead > 0) {
            let lineAsString = String.init(cString:lineByteArrayPointer!)
            let lineLinterResult = byLine(lineAsString, lineCounter)

            if !lineLinterResult && stopOnFailure {
                break
            }
            bytesRead = getline(&lineByteArrayPointer, &lineCap, filePointer)
            lineCounter += 1
        }
    }
}

public class CachingLintFileManager: LintFileManager {
    private var fileCache = [FileType: [URL]]()

    public init() { }

    public func preloadFiles(ofTypes types: [FileType], baseURL: URL, ignoreList: [FileIgnore]) {
        if let enumerator = FileManager.default.enumerator(
            at: baseURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) {
            for case let fileURL as URL in enumerator {
                guard !fileURL.isFiltered(by: ignoreList) else { continue }
                guard let fileType = fileURL.matches(types) else { continue }

                guard var urls = fileCache[fileType] else {
                    fileCache[fileType] = [fileURL]
                    continue
                }

                urls.append(fileURL)

                fileCache[fileType] = urls
            }
        }
    }

    public func files(ofType type: FileType, ignoreList: [FileIgnore]) -> [URL] {
        guard let files = fileCache[type] else { fatalError() }

        return files
    }
}
