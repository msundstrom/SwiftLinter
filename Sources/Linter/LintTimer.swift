import Foundation

class LintTimer {
    enum TimerType: String {
        case filePath, file, line
    }

    var startTimes: [String: DispatchTime] = [:]
    var endTimes: [String: DispatchTime] = [:]

    func start(`for` id: TimerType) {
        startTimes[id.rawValue] = .now()
    }

    func end(`for` id: TimerType) {
        endTimes[id.rawValue] = .now()
    }

    func time(`for` id: TimerType) -> String {
        guard
            let startTime = startTimes[id.rawValue],
            let endtime = endTimes[id.rawValue]
        else {
            return "----"
        }

        let nanoSeconds = endtime.uptimeNanoseconds - startTime.uptimeNanoseconds
        let fileTimeInterval = Double(nanoSeconds) / 1_000_000_000

        return "\(id): \(fileTimeInterval) seconds"
    }
}
