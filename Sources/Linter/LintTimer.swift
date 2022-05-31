import Foundation

class LintTimer {
    enum TimerType: String {
        case all, filePath, file, line
    }

    var startTimes: [String: DispatchTime] = [:]
    var endTimes: [String: DispatchTime] = [:]

    func start(`for` id: TimerType) {
        precondition(id != .all, "Cannot start with .all")
        startTimes[id.rawValue] = .now()
    }

    func end(`for` id: TimerType) {
        precondition(id != .all, "Cannot end with .all")
        guard startTimes[id.rawValue] != nil else {
            return
        }
        endTimes[id.rawValue] = .now()
    }

    func time(`for` id: TimerType) -> String {
        switch id {
        case .all:
            var totalTime: UInt64 = 0
            startTimes.forEach { (key: String, value: DispatchTime) in
                totalTime += endTimes[key]!.uptimeNanoseconds - value.uptimeNanoseconds
            }

            let timeInterval = Double(totalTime) / 1_000_000_000

            return "Total: \(timeInterval) seconds"
        case .filePath, .file, .line:
            guard
                let startTime = startTimes[id.rawValue],
                let endtime = endTimes[id.rawValue]
            else {
                return "----"
            }

            let nanoSeconds = endtime.uptimeNanoseconds - startTime.uptimeNanoseconds
            let timeInterval = Double(nanoSeconds) / 1_000_000_000

            return "\(id): \(timeInterval) seconds"
        }
    }
}
