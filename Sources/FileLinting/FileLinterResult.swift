import Foundation

public struct FileLinterResult: RuleResult {
    var result: ResultType
    var linterMessage: String
    var filePath: String = ""

    var message: String {
        "- \(linterMessage)"
    }
}

public extension FileLinterResult {
    static var passed: FileLinterResult {
        FileLinterResult(result: .passed, linterMessage: "")
    }

    static func warning(_ message: String) -> FileLinterResult {
        FileLinterResult(result: .warning, linterMessage: message)
    }

    static func failed(_ message: String) -> FileLinterResult {
        FileLinterResult(result: .failed, linterMessage: message)
    }
}
