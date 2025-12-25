import Combine
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var achievements: [Achievement] = []
    @Published var stats: ProductivityStats = ProductivityStats()
    
    private let storageService: StorageServiceProtocol
    private let settingsKey = "app_settings"
    private let achievementsKey = "achievements"
    
    init(storageService: StorageServiceProtocol = StorageService()) {
        self.storageService = storageService
        self.settings = storageService.load(AppSettings.self, forKey: settingsKey) ?? AppSettings()
        loadAchievements()
        loadStats()
        checkAchievements()
    }
    
    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
        storageService.save(settings, forKey: settingsKey)
        Logger.shared.info("Settings updated - Theme: \(newSettings.theme), Sounds: \(newSettings.soundsEnabled), Notifications: \(newSettings.notificationsEnabled)")
    }
    
    func loadStats() {
        let sessions = storageService.loadArray(PomodoroSession.self, forKey: "pomodoro_sessions")
        let habits = storageService.loadArray(Habit.self, forKey: "habits")
        let habitCompletions = storageService.loadArray(HabitCompletion.self, forKey: "habit_completions")
        let notes = storageService.loadArray(Note.self, forKey: "notes")
        
        stats.totalPomodoros = sessions.filter { $0.type == .work && $0.isCompleted }.count
        
        let completedSessions = sessions.filter { $0.type == .work && $0.isCompleted }
        if !completedSessions.isEmpty {
            let totalTime = completedSessions.reduce(0.0) { $0 + $1.duration }
            stats.averageFocusTime = totalTime / Double(completedSessions.count)
        }
        
        stats.habitsCompleted = habitCompletions.count
        stats.notesCreated = notes.count
        
        Logger.shared.debug("Stats loaded - Pomodoros: \(stats.totalPomodoros), Habits: \(stats.habitsCompleted), Notes: \(stats.notesCreated)")
    }
    
    private func loadAchievements() {
        achievements = storageService.loadArray(Achievement.self, forKey: achievementsKey)
        
        if achievements.isEmpty {
            initializeAchievements()
        }
    }
    
    private func initializeAchievements() {
        achievements = [
            Achievement(title: "First Steps", description: "Complete your first Pomodoro session", icon: "star.fill"),
            Achievement(title: "Productive Week", description: "Complete 7 Pomodoro sessions", icon: "calendar"),
            Achievement(title: "Habit Master", description: "Complete 10 habits", icon: "checkmark.circle.fill"),
            Achievement(title: "Writer", description: "Create 5 notes", icon: "note.text"),
            Achievement(title: "Reaction", description: "Score 20 points in reaction game", icon: "bolt.fill")
        ]
        saveAchievements()
    }
    
    func checkAchievements() {
        let sessions = storageService.loadArray(PomodoroSession.self, forKey: "pomodoro_sessions")
        let habitCompletions = storageService.loadArray(HabitCompletion.self, forKey: "habit_completions")
        let notes = storageService.loadArray(Note.self, forKey: "notes")
        let gameScores = storageService.loadArray(GameScore.self, forKey: "game_scores")
        
        var updated = false
        
        if sessions.contains(where: { $0.type == .work && $0.isCompleted }) {
            if let index = achievements.firstIndex(where: { $0.title == "First Steps" && !$0.isUnlocked }) {
                achievements[index].isUnlocked = true
                achievements[index].unlockedDate = Date()
                updated = true
            }
        }
        
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weekSessions = sessions.filter { $0.type == .work && $0.isCompleted && ($0.endDate ?? Date()) >= weekAgo }
        if weekSessions.count >= 7 {
            if let index = achievements.firstIndex(where: { $0.title == "Productive Week" && !$0.isUnlocked }) {
                achievements[index].isUnlocked = true
                achievements[index].unlockedDate = Date()
                updated = true
            }
        }
        
        if habitCompletions.count >= 10 {
            if let index = achievements.firstIndex(where: { $0.title == "Habit Master" && !$0.isUnlocked }) {
                achievements[index].isUnlocked = true
                achievements[index].unlockedDate = Date()
                updated = true
            }
        }
        
        if notes.count >= 5 {
            if let index = achievements.firstIndex(where: { $0.title == "Writer" && !$0.isUnlocked }) {
                achievements[index].isUnlocked = true
                achievements[index].unlockedDate = Date()
                updated = true
            }
        }
        
        let reactionScores = gameScores.filter { $0.gameType == "reaction" }
        if reactionScores.contains(where: { $0.score >= 20 }) {
            if let index = achievements.firstIndex(where: { $0.title == "Reaction" && !$0.isUnlocked }) {
                achievements[index].isUnlocked = true
                achievements[index].unlockedDate = Date()
                updated = true
            }
        }
        
        if updated {
            saveAchievements()
            Logger.shared.info("Achievements updated")
        }
    }
    
    private func saveAchievements() {
        storageService.saveArray(achievements, forKey: achievementsKey)
    }
}

