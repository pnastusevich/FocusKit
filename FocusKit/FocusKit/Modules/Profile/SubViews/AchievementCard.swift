import SwiftUI


struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.title)
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(12)
        .opacity(achievement.isUnlocked ? 1.0 : 0.5)
    }
}
