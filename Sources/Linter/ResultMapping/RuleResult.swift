import Foundation

protocol RuleResult {
    var result: ResultType { get }
    var filePath: String { get }
    var linterMessage: String { get }
    var message: String { get }
}
