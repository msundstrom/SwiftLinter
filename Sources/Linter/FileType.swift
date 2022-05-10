import Foundation

public enum FileType: Hashable {
    case swift, yaml, markdown
    case custom(NSRegularExpression)

    func matches(_ url: URL) -> Bool {
        switch self {
        case .swift:
            return url.fileType == "swift"
        case .yaml:
            return url.fileType == "yaml"
        case .markdown:
            return url.fileType == "md"
        case .custom(let regex):
            return regex.matches(url.path)
        }
    }
}

private extension URL {
    var fileType: String {
        let fileNameAndType = lastPathComponent.split(separator: ".")
        guard fileNameAndType.count == 2 else {
            return ""
        }
        return String(fileNameAndType[1])
    }
}
