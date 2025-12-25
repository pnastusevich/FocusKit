import Foundation

struct PomodoroSession: Codable, Identifiable {
    let id: UUID
    let duration: TimeInterval
    let startDate: Date
    var endDate: Date?
    let type: SessionType
    
    enum SessionType: String, Codable {
        case work
        case shortBreak
        case longBreak
    }
    
    var isCompleted: Bool {
        endDate != nil
    }
}

struct PomodoroSettings: Codable {
    var workDuration: TimeInterval = 25 * 60
    var shortBreakDuration: TimeInterval = 5 * 60
    var longBreakDuration: TimeInterval = 15 * 60
    var autoStartNext: Bool = true
    var sessionsUntilLongBreak: Int = 4
}

