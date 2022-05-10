import Foundation

public struct FilePathLinterResult: RuleResult {
    var result: ResultType
    var linterMessage: String
    var filePath: String = ""

    var message: String {
        "- \(linterMessage)"
    }
}

public extension FilePathLinterResult {
    static var passed: FilePathLinterResult {
        FilePathLinterResult(result: .passed, linterMessage: "")
    }

    static func warning(_ message: String) -> FilePathLinterResult {
        FilePathLinterResult(result: .warning, linterMessage: message)
    }

    static func failed(_ message: String) -> FilePathLinterResult {
        FilePathLinterResult(result: .failed, linterMessage: message)
    }
}
