import Foundation

public struct RegexMatch {
    public let match: String
    public let groups: [String]
    public let lineNumber: Int
}

public extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }

    func match(inFile string: String) async -> [RegexMatch] {
        let range = NSRange(location: 0, length: string.utf16.count)
        let allMatches = matches(in: string, options: [], range: range)

        return await withTaskGroup(
            of: RegexMatch.self,
            returning: [RegexMatch].self,
            body: { taskGroup in
                for match in allMatches {
                    taskGroup.addTask {
                        let fullMatch = string[match.range.lowerBound...match.range.upperBound]

                        var subMatches = [String]()
                        for matchIndex in 0..<match.numberOfRanges {
                            let subMatch = match.range(at: matchIndex)
                            let range = subMatch.lowerBound..<subMatch.upperBound
                            subMatches.append(string[range])
                        }

                        let beforeMatchString = string[0..<match.range.lowerBound]
                        let linesCount = beforeMatchString.reduce(into: 1) { (count, letter) in
                           if letter == "\n" {
                              count += 1
                           }
                        }

                        return RegexMatch(
                            match: fullMatch.trimmingCharacters(in: .whitespacesAndNewlines),
                            groups: subMatches,
                            lineNumber: linesCount
                        )
                    }
                }

                var results = [RegexMatch]()
                for await result in taskGroup {
                    results.append(result)
                }

                return results
            })

        var matches: [RegexMatch] = []
        for match in allMatches {
            let fullMatch = string[match.range.lowerBound...match.range.upperBound]

            var subMatches = [String]()
            for matchIndex in 0..<match.numberOfRanges {
                let subMatch = match.range(at: matchIndex)
//                let startIndex = string.index(string.startIndex, offsetBy: subMatch.lowerBound)
//                let endIndex = string.index(string.startIndex, offsetBy: subMatch.upperBound)
                let range = subMatch.lowerBound..<subMatch.upperBound
                subMatches.append(string[range])
            }

            let beforeMatchString = string[0..<match.range.lowerBound]
            let linesCount = beforeMatchString.reduce(into: 1) { (count, letter) in
               if letter == "\n" {
                  count += 1
               }
            }

            matches.append(RegexMatch(
                match: fullMatch.trimmingCharacters(in: .whitespacesAndNewlines),
                groups: subMatches,
                lineNumber: linesCount)
            )
        }

        return matches
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
