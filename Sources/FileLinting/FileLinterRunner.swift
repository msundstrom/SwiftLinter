import Foundation

public struct FileLinterRunner: SingleLinterRunner {
    let rule: FileLinterRule.Type
    let files: [URL]
    let baseURL: URL

    func run() async -> SingleLinterResults {
        var linterResult = SingleLinterResults(rule.name)

        parallelize(for: files) { fileURL in
            guard !fileURL.isFiltered(by: rule.ignoreList) else { return }

            do {
                let contents = try String(contentsOf: fileURL)
                let result = await rule.run(fileURL, contents: contents)

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
