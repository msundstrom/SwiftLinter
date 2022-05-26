import XCTest
@testable import SwiftLinter

class ResultTypeTests: XCTestCase {

    let passed = ResultType.passed
    let warning = ResultType.warning
    let failed = ResultType.failed

    func testLesserThanOperator() {
        XCTAssertLessThan(passed, warning)
        XCTAssertLessThan(passed, failed)

        XCTAssertLessThan(warning, failed)

        XCTAssertFalse(passed < passed)
        XCTAssertFalse(warning < warning)
        XCTAssertFalse(failed < failed)

        XCTAssertFalse(warning < passed)
        XCTAssertFalse(failed < passed)

        XCTAssertFalse(failed < warning)
    }

    func testGreaterThanOperator() {
        XCTAssertGreaterThan(warning, passed)
        XCTAssertGreaterThan(warning, passed)

        XCTAssertGreaterThan(failed, warning)

        XCTAssertFalse(passed > passed)
        XCTAssertFalse(warning > warning)
        XCTAssertFalse(failed > failed)

        XCTAssertFalse(passed > warning)
        XCTAssertFalse(passed > failed)

        XCTAssertFalse(warning > failed)
    }

    func testLessThanOrEqualOperator() {
        XCTAssertLessThanOrEqual(passed, passed)
        XCTAssertLessThanOrEqual(passed, warning)
        XCTAssertLessThanOrEqual(passed, failed)

        XCTAssertLessThanOrEqual(warning, warning)
        XCTAssertLessThanOrEqual(warning, failed)

        XCTAssertLessThanOrEqual(failed, failed)

        XCTAssertTrue(passed >= passed)
        XCTAssertTrue(warning >= warning)
        XCTAssertTrue(failed >= failed)

    }

    func testGreaterThanOrEqualOperator() {

        XCTAssertGreaterThanOrEqual(passed, passed)
        XCTAssertGreaterThanOrEqual(warning, warning)
        XCTAssertGreaterThanOrEqual(failed, failed)
        XCTAssertGreaterThanOrEqual(warning, passed)
        XCTAssertGreaterThanOrEqual(failed, warning)

        XCTAssertTrue(passed <= passed)
        XCTAssertTrue(warning <= warning)
        XCTAssertTrue(failed <= failed)


        XCTAssertTrue(passed <= warning)
        XCTAssertTrue(passed <= failed)

        XCTAssertTrue(warning <= failed)

    }
}
