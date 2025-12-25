import SwiftUI

struct TimerStatisticsView: View {
    let sessionsCompleted: Int
    let sessionsThisWeek: Int
    let isSmallScreen: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Text("\(sessionsCompleted)")
                    .font(isSmallScreen ? .title2 : .title)
                    .fontWeight(.bold)
                Text("Today")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: isSmallScreen ? 30 : 40)
            
            VStack {
                Text("\(sessionsThisWeek)")
                    .font(isSmallScreen ? .title2 : .title)
                    .fontWeight(.bold)
                Text("This Week")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(isSmallScreen ? 10 : 15)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.bottom, isSmallScreen ? 10 : 20)
    }
}

