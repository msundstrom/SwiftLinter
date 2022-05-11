
import XCTest

class RegexTester: XCTestCase {
    func testMultilineRegex() {
        let testString: String =
"""
import Foundation
import MapboxMaps

/// Handles the all the `RealTimeSpontAnnotation`s added and removed from the map.
protocol RealTimeSpotAnnotationManager {

    var annotations: [RealTimeSpotAnnotation] { get }

    /// Adds an annotation to the map, representing the provided `VacatedSpot`.
    /// - Parameter vacatedSpot: The spot to represent with an annotation.
    func add(_ vacatedSpot: VacatedSpot)

    func setVisibile(_ visible: Bool)
}

class DefaultRealTimeSpotAnnotationManager: RealTimeSpotAnnotationManager {
    private let viewAnnotationManager: ViewAnnotationManager
    private(set) var annotations = [RealTimeSpotAnnotation]()

    init(
        viewAnnotationManager: ViewAnnotationManager
    ) {
        self.viewAnnotationManager = viewAnnotationManager
    }
}

"""

        let regex = try! NSRegularExpression(pattern: #"^protocol\s"#, options: [.anchorsMatchLines])
        let match = regex.firstMatch(
            in: testString,
            options: [],
            range: NSRange(location: 0, length: testString.utf16.count))

        XCTAssertNotNil(match)
    }
}
