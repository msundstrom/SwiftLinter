import Foundation

protocol SingleLinterRunner {
    func run() async -> SingleLinterResults
}

extension SingleLinterRunner {
    func parallelize(for files: [URL], _ operation: (URL) -> Void) {
        DispatchQueue.concurrentPerform(iterations: files.count) { index in
            operation(files[index])
        }
    }
}

public class LinterRunner {
    private let baseURL: URL
    let fileManager: SwiftLinterFileManager
    let linterOptions: LinterOptions

    private var timerManager: TimerManager = TimerManager()

    private let filePathRules: [FilePathLinterRule.Type]
    private let fileRules: [FileLinterRule.Type]
    private let lineRules: [LineLinterRule.Type]

    public init(
        fileManager: SwiftLinterFileManager = CachingFileManager(),
        dir: String,
        linterOptions: LinterOptions,
        filePathRules: [FilePathLinterRule.Type],
        fileRules: [FileLinterRule.Type],
        lineRules: [LineLinterRule.Type]
    ) {
        self.fileManager = fileManager
        self.linterOptions = linterOptions
        self.filePathRules = filePathRules
        self.fileRules = fileRules
        self.lineRules = lineRules

        let url: URL
        if dir.isRelative {
            url = FileUtility.resolve(relativePath: dir)
        } else {
            url = URL(fileURLWithPath: dir)
        }

        baseURL = url.absoluteURL

        // set up timers
        timerManager.add(LintTimer(.file))
        timerManager.add(LintTimer(.filePath))
        timerManager.add(LintTimer(.filePreloading))
        timerManager.add(LintTimer(.line))
    }

    public func run() async -> Bool {
        var filePathResult = true
        var fileResult = true
        var lineResult = true


        var fileTypes: [FileType] = filePathRules.map({ $0.fileType })
        fileTypes.append(contentsOf: fileRules.map({ $0.fileType }))
        fileTypes.append(contentsOf: lineRules.map({ $0.fileType }))

        print("Preloading files...")
        timerManager.fetch(.filePreloading).start()
        fileManager.preloadFiles(
            ofTypes: fileTypes,
            baseURL: baseURL,
            ignoreList: linterOptions.ignorePaths
        )
        timerManager.fetch(.filePreloading).end()
        print("Preloading done! (\(timerManager.fetch(.filePreloading).formattedDuration(includeName: false)))")

        if filePathRules.count > 0 {
            timerManager.fetch(.filePath).start()
            filePathResult = await runFilePathLinters()
            timerManager.fetch(.filePath).end()
        }

        if fileRules.count > 0 {
            timerManager.fetch(.file).start()
            fileResult = await runFileLinters()
            timerManager.fetch(.file).end()
        }

        if lineRules.count > 0 {
            timerManager.fetch(.line).start()
            lineResult = await runLineLinters()
            timerManager.fetch(.line).end()
        }

        if linterOptions.printExecutionTime {

            if filePathRules.count > 0 {
                print(timerManager.fetch(.filePath).formattedDuration())
            }

            if fileRules.count > 0 {
                print(timerManager.fetch(.file).formattedDuration())
            }

            if lineRules.count > 0 {
                print(timerManager.fetch(.line).formattedDuration())
            }

            if
                filePathRules.count > 0 ||
                    fileRules.count > 0 ||
                    lineRules.count > 0 {
                //print(timer.time(for: .all))
            }
        }

        return filePathResult && fileResult && lineResult
    }

    private func runFilePathLinters() async -> Bool {
        let operations: [SingleLinterRunner] = filePathRules.map { rule in
            let files = fileManager.files(
                ofType: rule.fileType,
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
            let files = fileManager.files(
                ofType: rule.fileType,
                ignoreList: linterOptions.ignorePaths
            ).filter({ !$0.isFiltered(by: rule.ignoreList) })
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
            let files = fileManager.files(
                ofType: rule.fileType,
                ignoreList: linterOptions.ignorePaths
            ).filter({ !$0.isFiltered(by: rule.ignoreList) })
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
