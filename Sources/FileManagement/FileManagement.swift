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

public protocol SwiftLinterFileManager {
    func preloadFiles(ofTypes types: [FileType], baseURL: URL, ignoreList: [FileIgnore])
    func files(ofType type: FileType, ignoreList: [FileIgnore]) -> [URL]

}

public class CachingFileManager: SwiftLinterFileManager {
    private var fileCache = [FileType: [URL]]()

    public init() { }

    public func preloadFiles(
        ofTypes types: [FileType],
        baseURL: URL,
        ignoreList: [FileIgnore] = []
    ) {
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

    public func files(
        ofType type: FileType,
        ignoreList: [FileIgnore] = []
    ) -> [URL] {
        guard let files = fileCache[type] else { return [] }

        return files
    }
}
