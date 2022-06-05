import XCTest
@testable import SwiftLinter

class LineLinterResultTests: XCTestCase {
    func testMessageWithAllParametersSet() {
        let message = "Some message"
        let filePath = "/some/file/path.file"
        let line = "some line being linted"
        let lineNr = 42

        // passed
        let passedResult = LineLinterResult(
            result: .passed,
            linterMessage: message,
            filePath: filePath,
            line: line,
            lineNumber: lineNr
        )

        XCTAssertEqual(passedResult.message, "- \(message) (line \(lineNr), '\(line)')")

        // warning
        let warningResult = LineLinterResult(
            result: .warning,
            linterMessage: message,
            filePath: filePath,
            line: line,
            lineNumber: lineNr
        )

        XCTAssertEqual(warningResult.message, "- \(message) (line \(lineNr), '\(line)')")

        // failed
        let failedResult = LineLinterResult(
            result: .failed,
            linterMessage: message,
            filePath: filePath,
            line: line,
            lineNumber: lineNr
        )

        XCTAssertEqual(failedResult.message, "- \(message) (line \(lineNr), '\(line)')")
    }
}
