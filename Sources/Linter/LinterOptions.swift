import Foundation

public struct LinterOptions {
    let ignorePaths: [FileIgnore]
    let printExecutionTime: Bool

    public init(ignorePaths: [FileIgnore] = [], printExecutionTime: Bool = false) {
        self.ignorePaths = ignorePaths
        self.printExecutionTime = printExecutionTime
    }
}
