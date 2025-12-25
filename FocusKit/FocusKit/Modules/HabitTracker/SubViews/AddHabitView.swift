import SwiftUI

struct AddHabitView: View {
    @ObservedObject var viewModel: HabitTrackerViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    @State private var name = ""
    @State private var selectedColor = "blue"
    @State private var notificationsEnabled = false
    @State private var reminderInterval: HabitReminderInterval? = nil
    @State private var reminderTime = Date()
    @State private var reminderStartTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var reminderEndTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var reminderTimes: [Date] = []
    
    let colors = ["blue", "green", "red", "purple", "orange"]
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Habit name", text: $name)
            }
            
            Section(header: Text("Color")) {
                HStack(spacing: 20) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .fill(colorForName(color))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                            )
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                
                if notificationsEnabled {
                    Picker("Interval", selection: Binding(
                        get: { reminderInterval },
                        set: {
                            reminderInterval = $0
                            if $0 == .multipleTimes && reminderTimes.isEmpty {
                                let defaultTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
                                reminderTimes = [defaultTime]
                            }
                        }
                    )) {
                        Text("Not Selected").tag(HabitReminderInterval?.none)
                        ForEach(HabitReminderInterval.allCases, id: \.self) { interval in
                            Text(interval.displayName).tag(HabitReminderInterval?.some(interval))
                        }
                    }
                    
                    if reminderInterval == .onceADay {
                        DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                    
                    if reminderInterval == .hourly {
                        DatePicker("From", selection: $reminderStartTime, displayedComponents: .hourAndMinute)
                        DatePicker("To", selection: $reminderEndTime, displayedComponents: .hourAndMinute)
                    }
                    
                    if reminderInterval == .multipleTimes {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(reminderTimes.indices, id: \.self) { index in
                                HStack(spacing: 12) {
                                    DatePicker("Time \(index + 1)", selection: Binding(
                                        get: { reminderTimes[index] },
                                        set: { reminderTimes[index] = $0 }
                                    ), displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    
                                    Spacer()
                                    
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                        .onTapGesture {
                                            reminderTimes.remove(at: index)
                                        }
                                }
                            }
                            
                            HStack {
                                Spacer()
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Time")
                                }
                                .foregroundColor(.blue)
                                .font(.subheadline)
                                .onTapGesture {
                                    let defaultTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
                                    reminderTimes.append(defaultTime)
                                }
                                Spacer()
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationTitle("New Habit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    coordinator.dismissSheet()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    let habit = createHabit()
                    viewModel.addHabit(habit)
                    coordinator.dismissSheet()
                }
                .disabled(name.isEmpty || (notificationsEnabled && reminderInterval == nil))
            }
        }
    }
    
    private func createHabit() -> Habit {
        var habit = Habit(
            name: name,
            color: selectedColor,
            notificationsEnabled: notificationsEnabled
        )
        
        if notificationsEnabled {
            habit.reminderInterval = reminderInterval
            
            switch reminderInterval {
            case .onceADay:
                habit.reminderTime = reminderTime
            case .hourly:
                habit.reminderStartTime = reminderStartTime
                habit.reminderEndTime = reminderEndTime
            case .multipleTimes:
                habit.reminderTimes = reminderTimes.isEmpty ? nil : reminderTimes
            case .none:
                break
            }
        }
        
        return habit
    }
    
    private func colorForName(_ name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "green": return .green
        case "red": return .red
        case "purple": return .purple
        case "orange": return .orange
        default: return .blue
        }
    }
}

