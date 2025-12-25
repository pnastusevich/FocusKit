import SwiftUI
import UserNotifications

struct HabitTrackerView: View {
    @StateObject private var viewModel = HabitTrackerViewModel()
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.habits.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Habits")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Add your first habit")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.habits) { habit in
                            HabitRowView(habit: habit, viewModel: viewModel)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteHabit(viewModel.habits[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coordinator.presentSheet(.addHabit)
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.refreshHabits()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HabitsUpdated"))) { _ in
                viewModel.refreshHabits()
            }
            .onChange(of: coordinator.presentedSheet) { newValue in
                if newValue == nil {
                    viewModel.refreshHabits()
                }
            }
        }
    }
}






