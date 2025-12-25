import SwiftUI

struct TimerHeaderView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let isSmallScreen: Bool
    
    var body: some View {
        HStack {
            Text("Focus Timer")
                .font(isSmallScreen ? .title : .largeTitle)
                .fontWeight(.bold)
            Spacer()
            Button(action: {
                coordinator.presentSheet(.timerSettings)
            }) {
                Image(systemName: "gearshape.fill")
                    .font(isSmallScreen ? .title3 : .title2)
            }
        }
        .padding(.horizontal)
        .padding(.top, isSmallScreen ? 5 : 0)
    }
}

