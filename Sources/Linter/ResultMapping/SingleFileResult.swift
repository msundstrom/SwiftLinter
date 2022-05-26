import Foundation

struct SingleFileResult {
    let file: String
    var fileResult: ResultType = .passed
    var message: String {
        var summaryLines = [String]()
        let allWarnings: [String] = lineResults
            .filter({ $0.result == .warning })
            .compactMap({ $0.message })
        let allErrors: [String] = lineResults
            .filter({ $0.result == .failed })
            .compactMap({ $0.message })

        if allWarnings.count != 0 || allErrors.count != 0 {
            summaryLines.append("  \(file)")
        }
        allWarnings.forEach { warningString in
            summaryLines.append("    ⚠️ \(warningString)")
        }
        allErrors.forEach { errorString in
            summaryLines.append("    🛑 \(errorString)")
        }

        if summaryLines.count > 0 {
            return summaryLines.joined(separator: "\n") + "\n"
        } else {
            return "✅"
        }
    }

    private var lineResults = [RuleResult]()

    init(file: String) {
        self.file = file
    }

    mutating func add(_ singleLineResult: RuleResult) {
        if fileResult < singleLineResult.result {
            fileResult = singleLineResult.result
        }

        lineResults.append(singleLineResult)
    }
}
