import XCTest
@testable import SwiftLinter

class FileIgnoreTests: XCTestCase {

    func testExcludeCheckForFile() {
        let file = URL(fileURLWithPath: "/a/test/file/path.svg")
        let suffixFileEnding = "svg"
        XCTAssertTrue(FileIgnore.file(suffixFileEnding).shouldExclude(file))

        let suffixFile = "/path.svg"
        XCTAssertTrue(FileIgnore.file(suffixFile).shouldExclude(file))
    }

    func testExcludeCheckForPattern() {
        let file = URL(fileURLWithPath: "/a/test/file/path.svg")
        let pattern = #"\/file\/"#

        XCTAssertTrue(FileIgnore.pattern(pattern).shouldExclude(file))
    }

    func testPatternCheckReturnsFalseWithInvalidPattern() {
        let file = URL(fileURLWithPath: "/a/test/file\\****/")
        let pattern = #"\/file\****/"#

        XCTAssertFalse(FileIgnore.pattern(pattern).shouldExclude(file))
    }
}
