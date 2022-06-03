import Foundation

public struct SingleLineLinterRunner: SingleLinterRunner {
    let rule: LineLinterRule.Type
    let files: [URL]
    let baseURL: URL

    func run() async -> SingleLinterResults {
        var linterResult = SingleLinterResults(rule.name)
        parallelize(for: files) { fileURL in
            var fileResult = SingleFileResult(file: baseURL.reduce(fileURL))
            FileUtility.readLines(forFile: fileURL) { line, lineNr in
                let localPath = baseURL.reduce(fileURL)
                var result = rule.run(for: line, path: localPath)
                result.lineNumber = lineNr
                result.line = line.trimmingCharacters(in: .whitespacesAndNewlines)
                result.filePath = baseURL.reduce(fileURL)

                fileResult.add(result)
                return result.result == .passed
            }

            linterResult.add(fileResult: fileResult)
        }

        return linterResult
    }
}
