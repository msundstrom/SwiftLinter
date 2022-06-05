import XCTest
@testable import SwiftLinter

class FileUtilityTests: XCTestCase {
    let fileManager = CachingFileManager()
    var baseURL: URL {
        Bundle.module.bundleURL
    }

    override func setUp() {
        fileManager.preloadFiles(
            ofTypes: [.swift],
            baseURL: baseURL
        )
    }

    func testReadLines() {
        let protocolTestFileURL = fileManager.files(
            ofType: .swift,
            ignoreList: [
                .file("TestClasses.swift"),
                .file("TestStruct.swift")
            ]
        )

        var linesChecked: Int = 0

        FileUtility.readLines(forFile: protocolTestFileURL[0]) { line, lineNr in
            switch lineNr {
            case 1:
                XCTAssertEqual(line, "import Foundation")
                linesChecked += 1
            case 2:
                XCTAssertEqual(line, "")
                linesChecked += 1
            case 3:
                XCTAssertEqual(line, "protocol TestProtocol {")
                linesChecked += 1
            case 4:
                XCTAssertEqual(line, "")
                linesChecked += 1
            case 5:
                XCTAssertEqual(line, "}")
                linesChecked += 1
            default:
                XCTAssert(false, "Unexpected line number")
            }
            
            return true
        }

        XCTAssertEqual(linesChecked, 5)
    }

    func testReadLinesIgnoringEmptyLines() {
        let protocolTestFileURL = fileManager.files(
            ofType: .swift,
            ignoreList: [
                .file("TestClasses.swift"),
                .file("TestStruct.swift")
            ]
        )

        var linesChecked: Int = 0

        FileUtility.readLines(forFile: protocolTestFileURL[0], ignoreEmptyLines: true) { line, lineNr in
            switch lineNr {
            case 1:
                XCTAssertEqual(line, "import Foundation")
                linesChecked += 1
            case 3:
                XCTAssertEqual(line, "protocol TestProtocol {")
                linesChecked += 1
            case 5:
                XCTAssertEqual(line, "}")
                linesChecked += 1
            default:
                XCTAssert(false, "Unexpected line number")
            }

            return true
        }

        XCTAssertEqual(linesChecked, 3)
    }

    func testReadLinesCanStopOnLinterFailure() {
        let protocolTestFileURL = fileManager.files(
            ofType: .swift,
            ignoreList: [
                .file("TestClasses.swift"),
                .file("TestStruct.swift")
            ]
        )
        FileUtility.readLines(
            forFile: protocolTestFileURL[0],
            stopOnFailure: true
        ) { line, lineNr in

            if lineNr == 2 {
                return false
            } else if lineNr == 1 {
                return true
            }
            XCTAssertTrue(lineNr <= 2)
            return false
        }
    }
}
