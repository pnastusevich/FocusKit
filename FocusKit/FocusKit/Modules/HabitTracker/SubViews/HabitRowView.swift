
import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitTrackerViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        Button(action: {
            coordinator.presentSheet(.habitDetail(habit))
        }) {
            HStack {
                Button(action: {
                    viewModel.toggleCompletion(for: habit)
                }) {
                    Image(systemName: viewModel.isCompleted(habit) ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(habitColor)
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(habit.name)
                            .font(.headline)
                        
                        if habit.notificationsEnabled {
                            Image(systemName: "bell.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        Label("\(viewModel.completionCount(for: habit))", systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("\(viewModel.streak(for: habit))", systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
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
}
