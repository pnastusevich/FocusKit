import Foundation

enum HabitReminderInterval: String, Codable, CaseIterable {
    case onceADay = "once"
    case hourly = "hourly"
    case multipleTimes = "multiple"
    
    var displayName: String {
        switch self {
        case .onceADay: return "Once a Day"
        case .hourly: return "Hourly"
        case .multipleTimes: return "Multiple Times"
        }
    }
}

struct Habit: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var reminderTime: Date?
    var color: String
    var createdAt: Date
    var reminderInterval: HabitReminderInterval?
    var reminderStartTime: Date?
    var reminderEndTime: Date?
    var reminderTimes: [Date]?
    var notificationsEnabled: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        reminderTime: Date? = nil,
        color: String = "blue",
        createdAt: Date = Date(),
        reminderInterval: HabitReminderInterval? = nil,
        reminderStartTime: Date? = nil,
        reminderEndTime: Date? = nil,
        reminderTimes: [Date]? = nil,
        notificationsEnabled: Bool = false
    ) {
        self.id = id
        self.name = name
        self.reminderTime = reminderTime
        self.color = color
        self.createdAt = createdAt
        self.reminderInterval = reminderInterval
        self.reminderStartTime = reminderStartTime
        self.reminderEndTime = reminderEndTime
        self.reminderTimes = reminderTimes
        self.notificationsEnabled = notificationsEnabled
    }
}

struct HabitCompletion: Codable, Identifiable {
    let id: UUID
    let habitId: UUID
    let date: Date
    
    init(id: UUID = UUID(), habitId: UUID, date: Date = Date()) {
        self.id = id
        self.habitId = habitId
        self.date = Calendar.current.startOfDay(for: date)
    }
}

