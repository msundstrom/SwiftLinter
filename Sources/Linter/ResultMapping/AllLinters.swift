import Foundation

struct AllLinters {
    private let allLintersResults = SynchronizedArray<SingleLinterResults>()

    var totalOutcome: ResultType = .passed

    var message: String {
        allLintersResults
            .map({ $0.message })
            .joined(separator: "\n")
    }

    mutating func add(linterResult: SingleLinterResults) {
        if totalOutcome < linterResult.totalOutcome {
            totalOutcome = linterResult.totalOutcome
        }

        allLintersResults.append(linterResult)
    }
}
