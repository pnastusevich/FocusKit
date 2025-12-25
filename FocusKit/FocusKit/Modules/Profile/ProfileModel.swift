import Foundation

struct AppSettings: Codable {
    var theme: String = "system"
    var soundsEnabled: Bool = true
    var notificationsEnabled: Bool = true
    var gameDifficulty: String = "medium"
}

struct Achievement: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    init(id: UUID = UUID(), title: String, description: String, icon: String, isUnlocked: Bool = false, unlockedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
}

struct ProductivityStats: Codable {
    var totalPomodoros: Int = 0
    var averageFocusTime: TimeInterval = 0
    var habitsCompleted: Int = 0
    var notesCreated: Int = 0
}

