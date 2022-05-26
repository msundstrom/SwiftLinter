import Foundation

public struct RegexMatch {
    public let match: String
    public let lineNumber: Int
}

public extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }

    func match(inFile string: String) -> RegexMatch? {
        let range = NSRange(location: 0, length: string.utf16.count)
        let potentialMatch = firstMatch(in: string, options: [], range: range)

        guard let match = potentialMatch else {
            return nil
        }

        let matchString = string[match.range.lowerBound...match.range.upperBound]

        let beforeMatchString = string[0..<match.range.lowerBound]

        let linesCount = beforeMatchString.reduce(into: 1) { (count, letter) in
           if letter == "\n" {
              count += 1
           }
        }

        return RegexMatch(
            match: matchString.trimmingCharacters(in: .whitespacesAndNewlines),
            lineNumber: linesCount
        )
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
