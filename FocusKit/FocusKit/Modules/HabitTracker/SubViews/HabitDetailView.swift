import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitTrackerViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                        ForEach(0..<30) { dayOffset in
                            let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date()) ?? Date()
                            let isCompleted = viewModel.isCompleted(habit, on: date)
                            
                            VStack {
                                Text(dayOfWeek(for: date))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Circle()
                                    .fill(isCompleted ? habitColor : Color.gray.opacity(0.2))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Text("\(Calendar.current.component(.day, from: date))")
                                            .font(.caption2)
                                            .foregroundColor(isCompleted ? .white : .primary)
                                    )
                            }
                        }
                    }
                    .padding()
                }
                
                if habit.notificationsEnabled {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.blue)
                            Text("Notifications Enabled")
                                .font(.headline)
                        }
                        
                        if let interval = habit.reminderInterval {
                            Text(interval.displayName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            switch interval {
                            case .onceADay:
                                if let time = habit.reminderTime {
                                    Text("Time: \(formatTime(time))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            case .hourly:
                                if let start = habit.reminderStartTime,
                                   let end = habit.reminderEndTime {
                                    Text("From \(formatTime(start)) to \(formatTime(end))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            case .multipleTimes:
                                if let times = habit.reminderTimes, !times.isEmpty {
                                    Text("Times: \(times.map { formatTime($0) }.joined(separator: ", "))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Divider()
                        
                        NotificationListView(habit: habit)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                HStack(spacing: 40) {
                    VStack {
                        Text("\(viewModel.completionCount(for: habit, in: 7))")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("This Week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(viewModel.streak(for: habit))")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle(habit.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        coordinator.dismissSheet()
                    }
                }
            }
        }
    }
    
    private var habitColor: Color {
        switch habit.color {
        case "blue": return .blue
        case "green": return .green
        case "red": return .red
        case "purple": return .purple
        case "orange": return .orange
        default: return .blue
        }
    }
    
    private func dayOfWeek(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

