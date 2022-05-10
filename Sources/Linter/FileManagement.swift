import Foundation

struct FileManagement {
    private static var fileCache = [FileType: [URL]]()

    static func files(ofType type: FileType, at baseURL: URL, ignoreList: [FileIgnore]) -> [URL] {
        if let existingFiles = fileCache[type] {
            return existingFiles
        }

        var files = [URL]()
        if let enumerator = FileManager.default.enumerator(
            at: baseURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) {
            for case let fileURL as URL in enumerator {
                guard !fileURL.isFiltered(by: ignoreList) else { continue }

                if type.matches(fileURL) {
                    files.append(fileURL)
                }
            }
        }

        fileCache[type] = files
        return files
    }

    static func readLines(
        forFile fileURL: URL,
        stopOnFailure: Bool = false,
        _ byLine: (_ line: String, _ lineNr: Int) -> Bool
    ) {
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
