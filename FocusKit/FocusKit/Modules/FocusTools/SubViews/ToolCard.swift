import SwiftUI

struct ToolCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(color.opacity(0.1))
            .cornerRadius(15)
        }
    }
}

