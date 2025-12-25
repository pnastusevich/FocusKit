import SwiftUI

struct CoordinatorView: View {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            MainTabView()
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
                .sheet(item: Binding(
                    get: { coordinator.presentedSheet },
                    set: { _ in coordinator.dismissSheet() }
                )) { route in
                    sheetView(for: route)
                }
                .fullScreenCover(item: Binding(
                    get: { coordinator.presentedFullScreen },
                    set: { _ in coordinator.dismissFullScreen() }
                )) { route in
                    fullScreenView(for: route)
                }
        }
        .environmentObject(coordinator)
    }
    
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .noteDetail(let note):
            NoteDetailCoordinatorView(note: note)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func sheetView(for route: AppRoute) -> some View {
        switch route {
        case .addNote:
            AddNoteCoordinatorView()
        case .editNote(let note):
            EditNoteCoordinatorView(note: note)
        case .addHabit:
            AddHabitCoordinatorView()
        case .habitDetail(let habit):
            HabitDetailCoordinatorView(habit: habit)
        case .timerSettings:
            TimerSettingsCoordinatorView()
        case .profileSettings:
            ProfileSettingsCoordinatorView()
        case .focusTool(let toolType):
            if toolType != .focusMode {
                FocusToolCoordinatorView(toolType: toolType)
            } else {
                EmptyView()
            }
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func fullScreenView(for route: AppRoute) -> some View {
        switch route {
        case .focusTool(let toolType):
            if toolType == .focusMode {
                FocusModeView()
            } else {
                EmptyView()
            }
        default:
            EmptyView()
        }
    }
}

struct NoteDetailCoordinatorView: View {
    let note: Note
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = DailyLogViewModel()
    
    var body: some View {
        NoteDetailView(note: note, viewModel: viewModel)
    }
}

struct EditNoteCoordinatorView: View {
    let note: Note
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = DailyLogViewModel()
    
    var body: some View {
        NavigationView {
            AddNoteView(viewModel: viewModel, editingNote: note)
        }
    }
}

struct AddNoteCoordinatorView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = DailyLogViewModel()
    
    var body: some View {
        NavigationView {
            AddNoteView(viewModel: viewModel)
        }
    }
}

struct HabitDetailCoordinatorView: View {
    let habit: Habit
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = HabitTrackerViewModel()
    
    var body: some View {
        HabitDetailView(habit: habit, viewModel: viewModel)
    }
}

struct AddHabitCoordinatorView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = HabitTrackerViewModel()
    
    var body: some View {
        NavigationView {
            AddHabitView(viewModel: viewModel)
        }
    }
}

struct TimerSettingsCoordinatorView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = FocusTimerViewModel()
    
    var body: some View {
        NavigationView {
            TimerSettingsView(viewModel: viewModel)
        }
    }
}

struct ProfileSettingsCoordinatorView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            SettingsView(viewModel: viewModel)
        }
    }
}

struct FocusToolCoordinatorView: View {
    let toolType: FocusToolType
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = FocusToolsViewModel()
    
    var body: some View {
        Group {
            switch toolType {
            case .timer:
                TimerToolView(viewModel: viewModel)
            case .puzzle:
                PuzzleGameView(viewModel: viewModel)
            case .reaction:
                ReactionGameView(viewModel: viewModel)
            case .focusMode:
                FocusModeView()
            }
        }
    }
}

