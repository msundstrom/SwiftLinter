import Foundation

public struct LineLinterResult: RuleResult {
    let result: ResultType
    var linterMessage: String
    var filePath: String = ""
    var line: String = ""
    var lineNumber: Int = 0

    var message: String {
        "- \(linterMessage) (line \(lineNumber), '\(line)')"
    }
}

public extension LineLinterResult {
    static var passed: LineLinterResult {
        LineLinterResult(result: .passed, linterMessage: "")
    }

    static func warning(_ message: String) -> LineLinterResult {
        LineLinterResult(result: .warning, linterMessage: message)
    }

    static func failed(_ message: String) -> LineLinterResult {
        LineLinterResult(result: .failed, linterMessage: message)
    }
}
