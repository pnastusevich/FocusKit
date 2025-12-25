import SwiftUI

struct FocusTimerView: View {
    @StateObject private var viewModel = FocusTimerViewModel()
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let isSmallScreen = screenHeight < 700
            
            let circleSize: CGFloat = isSmallScreen ? min(screenHeight * 0.35, 220) : 280
            let circleLineWidth: CGFloat = isSmallScreen ? 15 : 20
            let timeFontSize: CGFloat = isSmallScreen ? 44 : 56
            let spacing: CGFloat = isSmallScreen ? 20 : 30
            let verticalPadding: CGFloat = isSmallScreen ? 30 : 40
            
            VStack(spacing: spacing) {
                TimerHeaderView(isSmallScreen: isSmallScreen)
                
                TimerProgressView(
                    progress: viewModel.progress,
                    timeRemaining: viewModel.timeRemaining,
                    sessionType: viewModel.currentSessionType,
                    circleSize: circleSize,
                    circleLineWidth: circleLineWidth,
                    timeFontSize: timeFontSize,
                    isSmallScreen: isSmallScreen,
                    verticalPadding: verticalPadding
                )
                
                TimerControlsView(
                    viewModel: viewModel,
                    isSmallScreen: isSmallScreen,
                    sessionColor: sessionColor
                )
                
                TimerStatisticsView(
                    sessionsCompleted: viewModel.sessionsCompleted,
                    sessionsThisWeek: viewModel.sessionsThisWeek,
                    isSmallScreen: isSmallScreen
                )
            }
        }
    }
    
    private var sessionColor: Color {
        switch viewModel.currentSessionType {
        case .work:
            return .red
        case .shortBreak:
            return .green
        case .longBreak:
            return .blue
        }
    }
}

