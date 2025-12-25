import SwiftUI
import UserNotifications

struct NotificationListView: View {
    let habit: Habit
    @State private var scheduledNotifications: [UNNotificationRequest] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Scheduled Notifications")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    loadNotifications()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .disabled(isLoading)
            }
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if scheduledNotifications.isEmpty {
                Text("No scheduled notifications")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Scheduled: \(scheduledNotifications.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(Array(scheduledNotifications.prefix(3)), id: \.identifier) { notification in
                    if let trigger = notification.trigger as? UNCalendarNotificationTrigger {
                        let dateComponents = trigger.dateComponents
                        let timeString = String(format: "%02d:%02d", dateComponents.hour ?? 0, dateComponents.minute ?? 0)
                        Text("• \(timeString) - \(notification.content.body)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                if scheduledNotifications.count > 3 {
                    Text("... and \(scheduledNotifications.count - 3) more")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            loadNotifications()
        }
    }
    
    private func loadNotifications() {
        isLoading = true
        HabitNotificationService.shared.getScheduledNotifications(for: habit) { notifications in
            scheduledNotifications = notifications
            isLoading = false
        }
    }
}
