import Foundation

public class LinterRunner {  
    let dir: String
    let printExecutionTime: Bool
    let globalIgnoreList: [FileIgnore]

    private var fileLinterStart: DispatchTime = DispatchTime(uptimeNanoseconds: 0)
    private var fileLinterEnd: DispatchTime = DispatchTime(uptimeNanoseconds: 0)
    private var lineLinterStart: DispatchTime = DispatchTime(uptimeNanoseconds: 0)
    private var lineLinterEnd: DispatchTime = DispatchTime(uptimeNanoseconds: 0)

    private let baseURL: URL

    private let filePathRules: [FilePathLinterRule.Type]
    private let lineRules: [LineLinterRule.Type]

    public init(
        dir: String,
        printExecutionTime: Bool,
        globalIgnoreList: [FileIgnore],
        filePathRules: [FilePathLinterRule.Type],
        lineRules: [LineLinterRule.Type]
    ) {
        self.dir = dir
        self.printExecutionTime = printExecutionTime
        self.globalIgnoreList = globalIgnoreList

        let url = URL(
            fileURLWithPath: dir,
            isDirectory: true,
            relativeTo: URL(string: FileManager.default.currentDirectoryPath)
        )

        baseURL = url.absoluteURL

        self.filePathRules = filePathRules
        self.lineRules = lineRules
    }

    public func run() -> Bool {
        var fileResult = true
        var lineResult = true
        if filePathRules.count > 0 {
            fileLinterStart = DispatchTime.now()
            fileResult = runFileLinters()
            fileLinterEnd = DispatchTime.now()
        }

        if lineRules.count > 0 {
            lineLinterStart = DispatchTime.now()
            lineResult = runLineLinters()
            lineLinterEnd = DispatchTime.now()
        }

        if printExecutionTime {
            let fileNanoTime = fileLinterEnd.uptimeNanoseconds - fileLinterStart.uptimeNanoseconds
            let fileTimeInterval = Double(fileNanoTime) / 1_000_000_000

            let lineNanoTime = lineLinterEnd.uptimeNanoseconds - lineLinterStart.uptimeNanoseconds
            let lineTimeInterval = Double(lineNanoTime) / 1_000_000_000

            if filePathRules.count > 0 {
                print("File linter: \(fileTimeInterval) seconds")
            }

            if lineRules.count > 0 {
                print("Line linter: \(lineTimeInterval) seconds")
            }
        }

        return fileResult && lineResult
    }

    private func runFileLinters() -> Bool {
        var allLinters = AllLinters()
        for linter in filePathRules {
            var linterResult = SingleLinterResults(linter.name)

            let files = FileManagement.files(
                ofType: linter.fileType,
                at: baseURL,
                ignoreList: globalIgnoreList)

            runOperations(for: files) { fileURL in
                guard !fileURL.isFiltered(by: linter.ignoreList) else { return }

                let result = linter.run(fileURL)

                var singleFileResult = SingleFileResult(file: baseURL.reduce(fileURL))
                singleFileResult.add(result)

                linterResult.add(fileResult: singleFileResult)
            }

            allLinters.add(linterResult: linterResult)
        }

        print(allLinters.message)

        return allLinters.totalOutcome == .passed
    }

    private func runLineLinters() -> Bool {
        var allLinters = AllLinters()
        for linter in lineRules {
            var linterResult = SingleLinterResults(linter.name)

            let files = FileManagement.files(
                ofType: linter.fileType,
                at: baseURL,
                ignoreList: globalIgnoreList)

            runOperations(for: files) { fileURL in
                guard !fileURL.isFiltered(by: linter.ignoreList) else { return }
                var fileResult = SingleFileResult(file: baseURL.reduce(fileURL))
                FileManagement.readLines(forFile: fileURL) { line, lineNr in
                    let localPath = baseURL.reduce(fileURL)
                    var result = linter.run(for: line, path: localPath)
                    result.lineNumber = lineNr
                    result.line = line
                    result.filePath = baseURL.reduce(fileURL)

                    fileResult.add(result)
                    return result.result == .passed
                }

                linterResult.add(fileResult: fileResult)
            }

            allLinters.add(linterResult: linterResult)
        }

        print(allLinters.message)

        return allLinters.totalOutcome == .passed
    }

    private func runOperations(for files: [URL], _ operation: (URL) -> Void) {
        DispatchQueue.concurrentPerform(iterations: files.count) { index in
            operation(files[index])
        }
    }
}
