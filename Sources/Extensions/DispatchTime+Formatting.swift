import Foundation

extension DispatchTime {
    var formatted: String {
        let formattedTime = Double(uptimeNanoseconds) / 1_000_000_000
        return "\(formattedTime) seconds"
    }

    static func -(lhs: DispatchTime, rhs: DispatchTime) -> DispatchTime {
        DispatchTime(uptimeNanoseconds: lhs.uptimeNanoseconds - rhs.uptimeNanoseconds)
    }
}
