import Foundation

class LintTimer {
    enum TimerType: String {
        case filePath = "File path", file = "File", line = "Line", filePreloading = "File preloading"
    }

    let type: TimerType
    var duration: DispatchTime {
        guard
            let startTime = startTime,
            let endTime = endTime
        else {
            return DispatchTime(uptimeNanoseconds: 0)
        }

        return endTime - startTime
    }

    private var startTime: DispatchTime? = nil
    private var endTime: DispatchTime? = nil

    init(_ type: TimerType) {
        self.type = type
    }

    func start() {
        startTime = .now()
    }

    func end() {
        endTime = .now()
    }

    func formattedDuration(includeName: Bool = true) -> String {
        "\(includeName ? type.rawValue + ": " : "")\(duration.formatted)"
    }
}

class TimerManager {
    private var timers = [LintTimer.TimerType: LintTimer]()

    func add(_ timer: LintTimer) {
        precondition(timers[timer.type] == nil, "Timer of type \"\(timer.type.rawValue)\" already added!")

        timers[timer.type] = timer
    }

    func fetch(_ timerType: LintTimer.TimerType) -> LintTimer {
        guard let timer = timers[timerType] else {
            fatalError("No timer found of type \"\(timerType.rawValue)\"!")
        }

        return timer
    }
}
