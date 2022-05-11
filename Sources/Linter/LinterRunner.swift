import Foundation



protocol SingleLinterRunner {
    func run() async -> SingleLinterResults
}

extension SingleLinterRunner {
    func parallelize<TypeThing>(for files: [TypeThing], _ operation: (TypeThing) -> Void) {
        DispatchQueue.concurrentPerform(iterations: files.count) { index in
            operation(files[index])
        }
    }
}

struct FilePathLinterRunner: SingleLinterRunner {
    let rule: FilePathLinterRule.Type
    let files: [URL]
    let baseURL: URL

    func run() async -> SingleLinterResults {
        var linterResult = SingleLinterResults(rule.name)

        parallelize(for: files) { fileURL in
            guard !fileURL.isFiltered(by: rule.ignoreList) else { return }

            let result = rule.run(fileURL)

            var singleFileResult = SingleFileResult(file: baseURL.reduce(fileURL))
            singleFileResult.add(result)

            linterResult.add(fileResult: singleFileResult)
        }

        return linterResult
    }
}

struct FileLinterRunner: SingleLinterRunner {
    let rule: FileLinterRule.Type
    let files: [URL]
    let baseURL: URL

    func run() async -> SingleLinterResults {
        var linterResult = SingleLinterResults(rule.name)

        parallelize(for: files) { fileURL in
            guard !fileURL.isFiltered(by: rule.ignoreList) else { return }

            do {
                let contents = try String(contentsOf: fileURL)
                let result = rule.run(fileURL, contents: contents)

                var singleFileResult = SingleFileResult(file: baseURL.reduce(fileURL))
                singleFileResult.add(result)

                linterResult.add(fileResult: singleFileResult)
            } catch {
                print(error)
            }
        }

        return linterResult
    }
}

struct SingleLineLinterRunner: SingleLinterRunner {
    let rule: LineLinterRule.Type
    let files: [URL]
    let baseURL: URL

    func run() async -> SingleLinterResults {
        var linterResult = SingleLinterResults(rule.name)
        parallelize(for: files) { fileURL in
            var fileResult = SingleFileResult(file: baseURL.reduce(fileURL))
            FileManagement.readLines(forFile: fileURL) { line, lineNr in
                let localPath = baseURL.reduce(fileURL)
                var result = rule.run(for: line, path: localPath)
                result.lineNumber = lineNr
                result.line = line
                result.filePath = baseURL.reduce(fileURL)

                fileResult.add(result)
                return result.result == .passed
            }

            linterResult.add(fileResult: fileResult)
        }

        return linterResult
    }
}



public class LinterRunner {  
    let dir: String
    let linterOptions: LinterOptions

    private var timer: LintTimer = LintTimer()

    private let baseURL: URL

    private let filePathRules: [FilePathLinterRule.Type]
    private let fileRules: [FileLinterRule.Type]
    private let lineRules: [LineLinterRule.Type]

    public init(
        dir: String,
        linterOptions: LinterOptions,
        filePathRules: [FilePathLinterRule.Type],
        fileRules: [FileLinterRule.Type],
        lineRules: [LineLinterRule.Type]
    ) {
        self.dir = dir
        self.linterOptions = linterOptions
        self.filePathRules = filePathRules
        self.fileRules = fileRules
        self.lineRules = lineRules

        let url: URL
        if dir.isRelative {
            url = URL(
                fileURLWithPath: dir,
                isDirectory: true,
                relativeTo: URL(string: FileManager.default.currentDirectoryPath)
            )
        } else {
            url = URL(fileURLWithPath: dir)
        }

        baseURL = url.absoluteURL
    }

    public func run() async -> Bool {
        var filePathResult = true
        var fileResult = true
        var lineResult = true

        if filePathRules.count > 0 {
            timer.start(for: .filePath)
            filePathResult = await runFilePathLinters()
            timer.end(for: .filePath)
        }

        if fileRules.count > 0 {
            timer.start(for: .file)
            fileResult = await runFileLinters()
            timer.end(for: .file)
        }

        if lineRules.count > 0 {
            timer.start(for: .line)
            lineResult = await runLineLinters()
            timer.end(for: .line)
        }

        if linterOptions.printExecutionTime {

            if filePathRules.count > 0 {
                print(timer.time(for: .filePath))
            }

            if fileRules.count > 0 {
                print(timer.time(for: .file))
            }

            if lineRules.count > 0 {
                print(timer.time(for: .line))
            }
        }

        return filePathResult && lineResult
    }

    private func runFilePathLinters() async -> Bool {
        let operations: [SingleLinterRunner] = filePathRules.map { rule in
            let files = FileManagement.files(
                ofType: rule.fileType,
                at: baseURL,
                ignoreList: linterOptions.ignorePaths
            )
            return FilePathLinterRunner(
                rule: rule,
                files: files,
                baseURL: baseURL
            )
        }

        let allLintersResult = await runLinterOperations(operations)
        return allLintersResult.totalOutcome == .passed
    }

    private func runFileLinters() async -> Bool {
        let operations: [SingleLinterRunner] = fileRules.map { rule in
            let files = FileManagement.files(
                ofType: rule.fileType,
                at: baseURL,
                ignoreList: linterOptions.ignorePaths
            )
            return FileLinterRunner(
                rule: rule,
                files: files,
                baseURL: baseURL
            )
        }

        let allLintersResult = await runLinterOperations(operations)
        return allLintersResult.totalOutcome == .passed
    }

    private func runLineLinters() async -> Bool {
        let operations: [SingleLinterRunner] = lineRules.map { rule in
            let files = FileManagement.files(
                ofType: rule.fileType,
                at: baseURL,
                ignoreList: linterOptions.ignorePaths
            )
            return SingleLineLinterRunner(
                rule: rule,
                files: files,
                baseURL: baseURL
            )
        }

        let allLintersResult = await runLinterOperations(operations)

        return allLintersResult.totalOutcome == .passed
    }

    private func runLinterOperations(_ operations: [SingleLinterRunner]) async -> AllLinters {
        var allResults: AllLinters!
        allResults = await withTaskGroup(
            of: SingleLinterResults.self,
            returning: AllLinters.self,
            body: { taskGroup in
            for operation in operations {
                taskGroup.addTask {
                    let value = await operation.run()
                    return value
                }
            }

            var results = AllLinters()
            for await result in taskGroup {
                results.add(linterResult: result)
            }

            return results
        })

        print(allResults.message)
        return allResults
    }
}
