import Foundation

public protocol FilePathLinterRule {
    static var name: String { get }
    static var description: String { get }
    static var fileType: FileType { get }
    static var ignoreList: [FileIgnore] { get }

    static func run(_ url: URL) -> FilePathLinterResult
}
