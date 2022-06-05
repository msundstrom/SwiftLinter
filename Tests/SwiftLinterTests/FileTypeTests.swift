import XCTest
@testable import SwiftLinter

class FileTypeTests: XCTestCase {
    func testFileTypeMatchesSwiftCorrectly() {
        let url = URL(fileURLWithPath: "some/path/withFile.swift")
        XCTAssertTrue(FileType.swift.matches(url))
    }

    func testFileTypeMatchesYamlCorrectly() {
        let url = URL(fileURLWithPath: "some/path/withFile.yaml")
        XCTAssertTrue(FileType.yaml.matches(url))
    }

    func testFileTypeMatchesMarkdownCorrectly() {
        let url = URL(fileURLWithPath: "some/path/withFile.md")
        XCTAssertTrue(FileType.markdown.matches(url))
    }

    func testFileTypeMatchesCustomCorrectly() {
        let url = URL(fileURLWithPath: "some/path/withFile.json2")
        XCTAssertTrue(FileType.custom(#"\.json2"#).matches(url))
    }
}
