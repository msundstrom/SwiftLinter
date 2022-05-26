import Foundation

enum ResultType: CaseIterable {
    case passed, warning, failed
}

extension ResultType: Comparable {
    static func < (lhs: ResultType, rhs: ResultType) -> Bool {
        switch lhs {
        case .passed:
            return (rhs == .warning || rhs == .failed)
        case .warning:
            return rhs == .failed
        case .failed:
            return false
        }
    }

    static func > (lhs: ResultType, rhs: ResultType) -> Bool {
        switch lhs {
        case .passed:
            return false
        case .warning:
            return rhs == .passed
        case .failed:
            return (rhs == .warning || rhs == .passed )
        }
    }

    static func >= (lhs: ResultType, rhs: ResultType) -> Bool {
        switch lhs {
        case .passed:
            return rhs == .passed
        case .warning:
            return (rhs == .warning || rhs == .passed)
        case .failed:
            return true
        }
    }

    static func <= (lhs: ResultType, rhs: ResultType) -> Bool {
        switch lhs {
        case .passed:
            return true
        case .warning:
            return rhs == .warning || rhs == .failed
        case .failed:
            return rhs == .failed
        }
    }
}
