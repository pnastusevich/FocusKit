import SwiftUI

struct TimerProgressView: View {
    let progress: Double
    let timeRemaining: TimeInterval
    let sessionType: PomodoroSession.SessionType
    let circleSize: CGFloat
    let circleLineWidth: CGFloat
    let timeFontSize: CGFloat
    let isSmallScreen: Bool
    let verticalPadding: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: circleLineWidth)
                .frame(width: circleSize, height: circleSize)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    sessionColor,
                    style: StrokeStyle(lineWidth: circleLineWidth, lineCap: .round)
                )
                .frame(width: circleSize, height: circleSize)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            
            VStack(spacing: isSmallScreen ? 5 : 10) {
                Text(timeString(from: timeRemaining))
                    .font(.system(size: timeFontSize, weight: .bold, design: .rounded))
                    .foregroundColor(sessionColor)
                
                Text(sessionTypeText)
                    .font(isSmallScreen ? .subheadline : .title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, verticalPadding)
    }
    
    private var sessionColor: Color {
        switch sessionType {
        case .work:
            return .red
        case .shortBreak:
            return .green
        case .longBreak:
            return .blue
        }
    }
    
    private var sessionTypeText: String {
        switch sessionType {
        case .work:
            return "Work"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

