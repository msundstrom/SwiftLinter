import Foundation

public struct FileLinterResult: RuleResult {
    var result: ResultType
    var linterMessage: String
    var filePath: String = ""
    var lineNumber: Int = 0
    var line: String = ""

    var message: String {
        "- \(linterMessage) (\(line) - line \(lineNumber))"
    }
}

public extension FileLinterResult {
    static var passed: FileLinterResult {
        FileLinterResult(
            result: .passed,
            linterMessage: ""
        )
    }

    static func warning(_ message: String, lineNumber: Int = 0, line: String = "") -> FileLinterResult {
        FileLinterResult(
            result: .warning,
            linterMessage: message,
            lineNumber: lineNumber,
            line: line
        )
    }

    static func failed(_ message: String) -> FileLinterResult {
        FileLinterResult(
            result: .failed,
            linterMessage: message
        )
    }

    static func failed(_ message: String, lineNumber: Int = 0, line: String = "") -> FileLinterResult {
        FileLinterResult(
            result: .failed,
            linterMessage: message,
            lineNumber: lineNumber,
            line: line
        )
    }
}
