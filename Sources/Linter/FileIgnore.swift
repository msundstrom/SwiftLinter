import Foundation

public enum FileIgnore {
    case file(String)
    case pattern(String)

    func shouldExclude(_ url: URL) -> Bool {
        switch self {
        case let .file(file):
            return url.path.hasSuffix(file)
        case let .pattern(pattern):
            return (try? NSRegularExpression(pattern: pattern).matches(url.path)) ?? false
        }
    }
}
