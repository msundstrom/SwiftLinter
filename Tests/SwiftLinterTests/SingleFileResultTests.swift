import XCTest
@testable import SwiftLinter

class SingleFileResultTests: XCTestCase {

    var singleFileResult: SingleFileResult!

    var file: String! = "TestFile"

    override func setUp() {
        singleFileResult = SingleFileResult(file: file)
    }

    func testAddPassedCreatesCorrectLineCount() {
        let resultCount = 5
        let results = createResults(amount: resultCount,
                                    with: .passed)

        for result in results {
            singleFileResult.add(result)
        }

        XCTAssertEqual(singleFileResult.message.lineCount, 0) // lineCount + title
    }

    func testAddWarningsCreatesCorrectLineCount() {
        let resultCount = 5
        let results = createResults(amount: resultCount,
                                    with: .warning)

        for result in results {
            singleFileResult.add(result)
        }

        XCTAssertEqual(singleFileResult.message.lineCount, 6) // lineCount + title
    }

    func testAddErrorsCreatesCorrectLineCount() {
        let resultCount = 5
        let results = createResults(amount: resultCount,
                                    with: .failed)

        for result in results {
            singleFileResult.add(result)
        }

        XCTAssertEqual(singleFileResult.message.lineCount, 6) // lineCount + title
    }

    func testFailedOvertakeWarningsAsFileResult() {
        let warningResult = createResults(amount: 1,
                                          with: .warning)[0]
        let failedResult = createResults(amount: 1,
                                         with: .failed)[0]

        XCTAssertEqual(singleFileResult.fileResult, .passed)

        singleFileResult.add(warningResult)
        XCTAssertEqual(singleFileResult.fileResult, .warning)

        singleFileResult.add(failedResult)
        XCTAssertEqual(singleFileResult.fileResult, .failed)
    }

    private func createResults(
        amount: Int,
        with result: ResultType
    ) -> [FilePathLinterResult] {
        (0..<amount).map { _ in
            FilePathLinterResult(result: result,
                                 linterMessage: "")
        }
    }
}

extension String {
    var lineCount: Int {
        self.components(separatedBy: .newlines).count - 1
    }
}
