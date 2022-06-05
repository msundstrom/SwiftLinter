import XCTest
@testable import SwiftLinter

class CachingFileManagementTests: XCTestCase {
    var baseURL: URL!
    private var sut: CachingFileManager!

    override func setUp() {
        sut = CachingFileManager()

        baseURL = Bundle.module.bundleURL
    }

    func testPreloadingSwiftFiles() {
        let fileType: FileType = .swift
        XCTAssertTrue(sut.files(ofType: fileType).isEmpty)

        sut.preloadFiles(ofTypes: [fileType], baseURL: baseURL)

        XCTAssertEqual(sut.files(ofType: fileType).count, 3)
    }

    func testPreloadingMarkdownFiles() {
        let fileType: FileType = .markdown
        XCTAssertTrue(sut.files(ofType: fileType).isEmpty)

        sut.preloadFiles(ofTypes: [fileType], baseURL: baseURL)

        XCTAssertEqual(sut.files(ofType: fileType).count, 1)
    }

    func testPreloadingFileTypesMatchingPattern() {
        let fileType: FileType = .custom(".json")
        XCTAssertTrue(sut.files(ofType: fileType).isEmpty)

        sut.preloadFiles(ofTypes: [fileType], baseURL: baseURL)

        XCTAssertEqual(sut.files(ofType: fileType).count, 1)
    }

    func testPreloadingFilesFilteredByGlobalIgnoreList() {
        let fileType: FileType = .swift
        XCTAssertTrue(sut.files(ofType: fileType).isEmpty)

        sut.preloadFiles(
            ofTypes: [fileType],
            baseURL: baseURL,
            ignoreList: [.pattern("Protocol")]
        )

        XCTAssertEqual(sut.files(ofType: fileType).count, 2)
    }
}
