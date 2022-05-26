import Foundation

public protocol LineLinterRule {
    static var name: String { get }
    static var description: String { get }
    static var fileType: FileType { get }
    static var ignoreList: [FileIgnore] { get }

    static func run(for line: String, path: String) -> LineLinterResult
}
