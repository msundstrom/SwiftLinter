import Foundation

enum ResultType {
    case passed, warning, failed
}

extension ResultType: Comparable {
    static func < (lhs: ResultType, rhs: ResultType) -> Bool {
        if lhs == .passed && (rhs == .warning || rhs == .failed) {
            return true
        } else if lhs == .warning && rhs == .failed {
            return true
        }

        return false
    }

    static func > (lhs: ResultType, rhs: ResultType) -> Bool {
        if (lhs == .warning || lhs == .failed) && rhs == .passed {
            return true
        } else if lhs == .failed && rhs == .warning {
            return true
        }

        return false
    }

    static func >= (lhs: ResultType, rhs: ResultType) -> Bool {
        switch rhs {
        case .passed:
            return true
        case .warning:
            if lhs == .failed || lhs == .warning {
                return true
            }
        case .failed:
            if lhs == .failed {
                return true
            }
        }

        return false
    }

    static func <= (lhs: ResultType, rhs: ResultType) -> Bool {
        switch lhs {
        case .passed:
            return true
        case .warning:
            if rhs == .warning || rhs == .failed {
                return true
            }
        case .failed:
            if rhs == .failed {
                return true
            }
        }

        return false
    }
}
