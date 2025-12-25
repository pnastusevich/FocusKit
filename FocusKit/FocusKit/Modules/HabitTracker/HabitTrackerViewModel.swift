import Combine
import SwiftUI

@MainActor
final class HabitTrackerViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var completions: [HabitCompletion] = []
    
    private let storageService: StorageServiceProtocol
    private let notificationService = HabitNotificationService.shared
    private let habitsKey = "habits"
    private let completionsKey = "habit_completions"
    
    init(storageService: StorageServiceProtocol = StorageService()) {
        self.storageService = storageService
        loadHabits()
        loadCompletions()
        scheduleAllNotifications()
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
        Logger.shared.info("Habit added: \(habit.name), Notifications: \(habit.notificationsEnabled)")
        
        if habit.notificationsEnabled {
            notificationService.scheduleNotifications(for: habit)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("HabitsUpdated"), object: nil)
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            notificationService.cancelNotifications(for: habits[index])
            
            habits[index] = habit
            saveHabits()
            Logger.shared.info("Habit updated: \(habit.name)")
            
            if habit.notificationsEnabled {
                notificationService.scheduleNotifications(for: habit)
            }
        } else {
            Logger.shared.warning("Failed to update habit: \(habit.name) - not found")
        }
    }
    
    func refreshHabits() {
        loadHabits()
        scheduleAllNotifications()
    }
    
    func deleteHabit(_ habit: Habit) {
        notificationService.cancelNotifications(for: habit)
        
        habits.removeAll { $0.id == habit.id }
        completions.removeAll { $0.habitId == habit.id }
        saveHabits()
        saveCompletions()
        Logger.shared.info("Habit deleted: \(habit.name)")
    }
    
    private func scheduleAllNotifications() {
        for habit in habits where habit.notificationsEnabled {
            notificationService.scheduleNotifications(for: habit)
        }
    }
    
    func toggleCompletion(for habit: Habit, on date: Date = Date()) {
        let dayStart = Calendar.current.startOfDay(for: date)
        
        if let index = completions.firstIndex(where: { 
            $0.habitId == habit.id && Calendar.current.isDate($0.date, inSameDayAs: dayStart)
        }) {
            completions.remove(at: index)
            Logger.shared.debug("Habit completion removed: \(habit.name) for date: \(dayStart)")
        } else {
            let completion = HabitCompletion(habitId: habit.id, date: dayStart)
            completions.append(completion)
            Logger.shared.debug("Habit completion added: \(habit.name) for date: \(dayStart)")
        }
        saveCompletions()
    }
    
    func isCompleted(_ habit: Habit, on date: Date = Date()) -> Bool {
        let dayStart = Calendar.current.startOfDay(for: date)
        return completions.contains { 
            $0.habitId == habit.id && Calendar.current.isDate($0.date, inSameDayAs: dayStart)
        }
    }
    
    func completionCount(for habit: Habit, in days: Int = 7) -> Int {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return completions.filter { 
            $0.habitId == habit.id && $0.date >= startDate
        }.count
    }
    
    func streak(for habit: Habit) -> Int {
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        while isCompleted(habit, on: currentDate) {
            streak += 1
            guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDate
        }
        
        return streak
    }
    
    private func loadHabits() {
        habits = storageService.loadArray(Habit.self, forKey: habitsKey)
    }
    
    private func saveHabits() {
        storageService.saveArray(habits, forKey: habitsKey)
    }
    
    private func loadCompletions() {
        completions = storageService.loadArray(HabitCompletion.self, forKey: completionsKey)
    }
    
    private func saveCompletions() {
        storageService.saveArray(completions, forKey: completionsKey)
    }
}

