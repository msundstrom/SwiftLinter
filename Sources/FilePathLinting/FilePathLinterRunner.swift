import Foundation

public struct FilePathLinterRunner: SingleLinterRunner {
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
