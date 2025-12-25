import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Statistics")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            StatCard(title: "Pomodoro", value: "\(viewModel.stats.totalPomodoros)", icon: "timer", color: .red)
                            StatCard(title: "Avg Time", value: timeString(from: viewModel.stats.averageFocusTime), icon: "clock", color: .blue)
                            StatCard(title: "Habits", value: "\(viewModel.stats.habitsCompleted)", icon: "checkmark.circle", color: .green)
                            StatCard(title: "Notes", value: "\(viewModel.stats.notesCreated)", icon: "note.text", color: .purple)
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Achievements")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(viewModel.achievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Button(action: {
                        coordinator.presentSheet(.profileSettings)
                    }) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                            Text("Settings")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .onAppear {
                viewModel.loadStats()
                viewModel.checkAchievements()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HabitsUpdated"))) { _ in
                viewModel.loadStats()
                viewModel.checkAchievements()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NotesUpdated"))) { _ in
                viewModel.loadStats()
                viewModel.checkAchievements()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PomodoroSessionsUpdated"))) { _ in
                viewModel.loadStats()
                viewModel.checkAchievements()
            }
            .onChange(of: coordinator.presentedSheet) { newValue in
                if newValue == nil {
                    viewModel.loadStats()
                    viewModel.checkAchievements()
                }
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        return "\(minutes) min"
    }
}






