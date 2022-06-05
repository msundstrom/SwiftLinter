import Foundation

struct FileUtility {
    static func resolve(relativePath path: String) -> URL {
        URL(
            fileURLWithPath: path,
            isDirectory: true,
            relativeTo: URL(string: FileManager.default.currentDirectoryPath)
        )
    }

    static func readLines(
        forFile fileURL: URL,
        stopOnFailure: Bool = false,
        ignoreEmptyLines: Bool = false,
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
            let lineAsString = String.init(cString:lineByteArrayPointer!).trimmingCharacters(in: .whitespacesAndNewlines)
            if lineAsString == "" && ignoreEmptyLines {
                bytesRead = getline(&lineByteArrayPointer, &lineCap, filePointer)
                lineCounter += 1
                continue
            }
            let lineLinterResult = byLine(lineAsString, lineCounter)

            if !lineLinterResult && stopOnFailure {
                break
            }
            bytesRead = getline(&lineByteArrayPointer, &lineCap, filePointer)
            lineCounter += 1
        }
    }
}
