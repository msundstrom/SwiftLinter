import Foundation

struct SingleLinterResults {
    var linterName: String
    var totalOutcome: ResultType = .passed

    private var allFilesResults = SynchronizedArray<SingleFileResult>()

    var message: String {
        let linterTitle = "Running \(linterName)..."
        let messages = allFilesResults
            .filter({ $0.fileResult >= .warning })
            .map({ $0.message })
            .joined(separator: "\n")

        return "\([linterTitle, messages].joined(separator: "\n"))\n"
    }

    init(_ linterName: String) {
        self.linterName = linterName
    }

    mutating func add(fileResult: SingleFileResult) {
        if totalOutcome < fileResult.fileResult {
            totalOutcome = fileResult.fileResult
        }

        allFilesResults.append(fileResult)
    }
}
