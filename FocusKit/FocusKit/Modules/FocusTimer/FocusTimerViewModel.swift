import Foundation
import Combine
import UserNotifications

@MainActor
final class FocusTimerViewModel: ObservableObject {
    @Published var timeRemaining: TimeInterval = 25 * 60
    @Published var isRunning: Bool = false
    @Published var currentSessionType: PomodoroSession.SessionType = .work
    @Published var progress: Double = 0.0
    @Published var sessionsCompleted: Int = 0
    @Published var sessionsThisWeek: Int = 0
    
    private var timer: Timer?
    private let storageService: StorageServiceProtocol
    private var currentSession: PomodoroSession?
    private var settings: PomodoroSettings
    private var sessionCount: Int = 0
    
    private let sessionsKey = "pomodoro_sessions"
    private let settingsKey = "pomodoro_settings"
    
    init(storageService: StorageServiceProtocol = StorageService()) {
        self.storageService = storageService
        self.settings = storageService.load(PomodoroSettings.self, forKey: settingsKey) ?? PomodoroSettings()
        self.timeRemaining = settings.workDuration
        loadStatistics()
    }
    
    var totalDuration: TimeInterval {
        switch currentSessionType {
        case .work:
            return settings.workDuration
        case .shortBreak:
            return settings.shortBreakDuration
        case .longBreak:
            return settings.longBreakDuration
        }
    }
    
    func startTimer() {
        guard !isRunning else { return }
        
        if currentSession == nil {
            startNewSession()
        }
        
        isRunning = true
        Logger.shared.info("Timer started - Type: \(currentSessionType), Duration: \(totalDuration)")
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        Logger.shared.info("Timer paused - Time remaining: \(timeRemaining)")
    }
    
    func resetTimer() {
        pauseTimer()
        timeRemaining = totalDuration
        progress = 0.0
        currentSession = nil
        Logger.shared.info("Timer reset")
    }
    
    func skipSession() {
        if let session = currentSession {
            completeSession(session)
        }
        startNextSession()
    }
    
    func updateWorkDuration(_ minutes: Int) {
        let duration = TimeInterval(minutes * 60)
        guard duration >= 25 * 60 && duration <= 50 * 60 else {
            Logger.shared.warning("Invalid work duration: \(minutes) minutes")
            return
        }
        settings.workDuration = duration
        storageService.save(settings, forKey: settingsKey)
        Logger.shared.info("Work duration updated to \(minutes) minutes")
        
        if currentSessionType == .work && !isRunning {
            timeRemaining = duration
        }
    }
    
    private func startNewSession() {
        let session = PomodoroSession(
            id: UUID(),
            duration: totalDuration,
            startDate: Date(),
            endDate: nil,
            type: currentSessionType
        )
        currentSession = session
        timeRemaining = totalDuration
        progress = 0.0
    }
    
    private func tick() {
        guard timeRemaining > 0 else {
            completeCurrentSession()
            return
        }
        
        timeRemaining -= 1.0
        progress = 1.0 - (timeRemaining / totalDuration)
    }
    
    private func completeCurrentSession() {
        pauseTimer()
        
        if let session = currentSession {
            completeSession(session)
        }
        
        Logger.shared.info("Session completed - Type: \(currentSessionType), Auto-start: \(settings.autoStartNext)")
        
        if settings.autoStartNext {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.startNextSession()
            }
        } else {
            timeRemaining = totalDuration
            progress = 0.0
        }
        
        sendNotification()
    }
    
    private func completeSession(_ session: PomodoroSession) {
        var completedSession = session
        completedSession.endDate = Date()
        
        var sessions = storageService.loadArray(PomodoroSession.self, forKey: sessionsKey)
        sessions.append(completedSession)
        storageService.saveArray(sessions, forKey: sessionsKey)
        
        if session.type == .work {
            sessionsCompleted += 1
            sessionCount += 1
        }
        
        loadStatistics()
        
        NotificationCenter.default.post(name: NSNotification.Name("PomodoroSessionsUpdated"), object: nil)
    }
    
    private func startNextSession() {
        if currentSessionType == .work {
            sessionCount += 1
            if sessionCount >= settings.sessionsUntilLongBreak {
                currentSessionType = .longBreak
                sessionCount = 0
            } else {
                currentSessionType = .shortBreak
            }
        } else {
            currentSessionType = .work
        }
        
        startNewSession()
        startTimer()
    }
    
    private func loadStatistics() {
        let sessions = storageService.loadArray(PomodoroSession.self, forKey: sessionsKey)
        let today = Calendar.current.startOfDay(for: Date())
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) ?? today
        
        sessionsCompleted = sessions.filter { session in
            session.type == .work &&
            session.isCompleted &&
            Calendar.current.isDate(session.endDate ?? Date(), inSameDayAs: today)
        }.count
        
        sessionsThisWeek = sessions.filter { session in
            session.type == .work &&
            session.isCompleted &&
            (session.endDate ?? Date()) >= weekAgo
        }.count
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Focus Timer"
        content.body = currentSessionType == .work ? "Work session completed! Take a break." : "Break finished! Time to work."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
