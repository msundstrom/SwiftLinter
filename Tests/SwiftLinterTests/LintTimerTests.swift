import XCTest
@testable import SwiftLinter

extension String {
    func matches(regex: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: regex)
        return regex.matches(self)
    }
}

class LintTimerTests: XCTestCase {

    var timer: LintTimer!

    override func setUp() {
        timer = LintTimer()
    }

    func testSetsStartTime() {
        XCTAssertEqual(timer.startTimes.count, 0)
        timer.start(for: .file)
        XCTAssertEqual(timer.startTimes.count, 1)
    }

    func testSetsEndTimeIfStarted() {
        XCTAssertEqual(timer.endTimes.count, 0)
        timer.start(for: .file)
        timer.end(for: .file)
        XCTAssertEqual(timer.endTimes.count, 1)
    }

    func testDoesNotSetEndTimeIfNotStarted() {
        XCTAssertEqual(timer.endTimes.count, 0)
        timer.end(for: .file)
        XCTAssertEqual(timer.endTimes.count, 0)
    }

    func testGetsTotalTime() {
        timer.start(for: .file)
        timer.start(for: .filePath)
        timer.start(for: .line)

        Thread.sleep(forTimeInterval: 2)

        timer.end(for: .file)
        timer.end(for: .filePath)
        timer.end(for: .line)

        let regexString = #"Total:\s[0-9\.]+\sseconds"#
        let result = timer.time(for: .all)

        XCTAssertTrue(result.matches(regex: regexString))
    }

    func testGetsFileTime() {
        timer.start(for: .file)

        Thread.sleep(forTimeInterval: 0.5)

        timer.end(for: .file)

        let regexString = #"file:\s[0-9\.]+\sseconds"#
        let result = timer.time(for: .file)

        XCTAssertTrue(result.matches(regex: regexString))
    }

    func testGetsFilePathTime() {
        timer.start(for: .filePath)

        Thread.sleep(forTimeInterval: 0.5)

        timer.end(for: .filePath)

        let regexString = #"filePath:\s[0-9\.]+\sseconds"#
        let result = timer.time(for: .filePath)

        XCTAssertTrue(result.matches(regex: regexString))
    }

    func testGetsLineTime() {
        timer.start(for: .line)

        Thread.sleep(forTimeInterval: 0.5)

        timer.end(for: .line)

        let regexString = #"line:\s[0-9\.]+\sseconds"#
        let result = timer.time(for: .line)

        XCTAssertTrue(result.matches(regex: regexString))
    }

    func testErrorGettingTimeWhenNotEnded() {
        timer.start(for: .line)

        Thread.sleep(forTimeInterval: 0.5)

        let result = timer.time(for: .line)
        XCTAssertTrue(result.matches(regex: #"----"#))
    }
}
