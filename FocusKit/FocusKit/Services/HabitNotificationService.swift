import Foundation
import UserNotifications

@MainActor
final class HabitNotificationService {
    static let shared = HabitNotificationService()
    
    private init() {}
    
    func scheduleNotifications(for habit: Habit) {
        cancelNotifications(for: habit)
        
        guard habit.notificationsEnabled else {
            Logger.shared.debug("Notifications disabled for habit: \(habit.name)")
            return
        }
        
        let identifier = habit.id.uuidString
        Logger.shared.info("Scheduling notifications for habit: \(habit.name), Interval: \(habit.reminderInterval?.rawValue ?? "none")")
        
        switch habit.reminderInterval {
        case .onceADay:
            if let time = habit.reminderTime {
                scheduleDailyNotification(habit: habit, time: time, identifier: identifier)
            }
            
        case .hourly:
            if let startTime = habit.reminderStartTime,
               let endTime = habit.reminderEndTime {
                scheduleHourlyNotifications(habit: habit, startTime: startTime, endTime: endTime, identifier: identifier)
            }
            
        case .multipleTimes:
            if let times = habit.reminderTimes {
                scheduleMultipleNotifications(habit: habit, times: times, identifier: identifier)
            }
            
        case .none:
            if let time = habit.reminderTime {
                scheduleDailyNotification(habit: habit, time: time, identifier: identifier)
            }
        }
    }
    
    func cancelNotifications(for habit: Habit) {
        let identifier = habit.id.uuidString
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.hasPrefix(identifier) }
                .map { $0.identifier }
            
            if !identifiersToRemove.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
                Logger.shared.info("Cancelled \(identifiersToRemove.count) notifications for habit: \(habit.name)")
            }
        }
    }
    
    private func scheduleDailyNotification(habit: Habit, time: Date, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Don't forget: \(habit.name)"
        content.sound = .default
        content.userInfo = ["habitId": habit.id.uuidString]
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.shared.error("Error scheduling notification: \(error.localizedDescription)")
            } else {
                Logger.shared.debug("Daily notification scheduled for habit: \(habit.name)")
            }
        }
    }
    
    private func scheduleHourlyNotifications(habit: Habit, startTime: Date, endTime: Date, identifier: String) {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        guard let startHour = startComponents.hour,
              let startMinute = startComponents.minute,
              let endHour = endComponents.hour,
              let endMinute = endComponents.minute else { return }
        
        var currentHour = startHour
        let endHourValue = endHour
        
        while currentHour <= endHourValue {
            let content = UNMutableNotificationContent()
            content.title = "Habit Reminder"
            content.body = "Don't forget: \(habit.name)"
            content.sound = .default
            content.userInfo = ["habitId": habit.id.uuidString]
            
            var dateComponents = DateComponents()
            dateComponents.hour = currentHour
            dateComponents.minute = currentHour == startHour ? startMinute : 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let requestIdentifier = "\(identifier)_\(currentHour)"
            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    Logger.shared.error("Error scheduling hourly notification: \(error.localizedDescription)")
                } else {
                    Logger.shared.debug("Hourly notification scheduled for habit: \(habit.name) at hour: \(currentHour)")
                }
            }
            
            currentHour += 1
        }
    }
    
    private func scheduleMultipleNotifications(habit: Habit, times: [Date], identifier: String) {
        let calendar = Calendar.current
        
        for (index, time) in times.enumerated() {
            let components = calendar.dateComponents([.hour, .minute], from: time)
            
            let content = UNMutableNotificationContent()
            content.title = "Habit Reminder"
            content.body = "Don't forget: \(habit.name)"
            content.sound = .default
            content.userInfo = ["habitId": habit.id.uuidString]
            
            var dateComponents = DateComponents()
            dateComponents.hour = components.hour
            dateComponents.minute = components.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let requestIdentifier = "\(identifier)_\(index)"
            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    Logger.shared.error("Error scheduling multiple notification: \(error.localizedDescription)")
                } else {
                    Logger.shared.debug("Multiple notification scheduled for habit: \(habit.name) at index: \(index)")
                }
            }
        }
    }
    
    func sendTestNotification(for habit: Habit, completion: @escaping (Bool, String) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus != .authorized {
                completion(false, "Уведомления не разрешены. Проверьте настройки приложения.")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Test Notification"
            content.subtitle = "Habit Reminder"
            content.body = "Don't forget: \(habit.name)"
            content.sound = .default
            content.userInfo = ["habitId": habit.id.uuidString, "isTest": true]
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(
                identifier: "test_\(habit.id.uuidString)_\(UUID().uuidString)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    Logger.shared.error("Error sending test notification: \(error.localizedDescription)")
                    completion(false, "Error: \(error.localizedDescription)")
                } else {
                    Logger.shared.info("Test notification scheduled for habit: \(habit.name)")
                    completion(true, "Notification will be shown in 1 second. Minimize the app or wait.")
                }
            }
        }
    }
    
    func checkNotificationPermission(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }
    
    func getScheduledNotifications(for habit: Habit, completion: @escaping ([UNNotificationRequest]) -> Void) {
        let identifier = habit.id.uuidString
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let habitNotifications = requests.filter { request in
                request.identifier == identifier || request.identifier.hasPrefix("\(identifier)_")
            }
            completion(habitNotifications)
        }
    }
    
    func getAllScheduledNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            completion(requests)
        }
    }
}

