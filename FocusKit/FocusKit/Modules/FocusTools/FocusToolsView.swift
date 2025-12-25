import SwiftUI

struct FocusToolsView: View {
    @StateObject private var viewModel = FocusToolsViewModel()
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ToolCard(
                        title: "Stopwatch",
                        icon: "stopwatch.fill",
                        color: .blue
                    ) {
                        coordinator.presentSheet(.focusTool(.timer))
                    }
                    
                    ToolCard(
                        title: "Puzzle",
                        icon: "square.grid.3x3.fill",
                        color: .green
                    ) {
                        coordinator.presentSheet(.focusTool(.puzzle))
                    }
                    
                    ToolCard(
                        title: "Reaction",
                        icon: "hand.tap.fill",
                        color: .orange
                    ) {
                        coordinator.presentSheet(.focusTool(.reaction))
                    }
                    
                    ToolCard(
                        title: "Focus",
                        icon: "eye.fill",
                        color: .purple
                    ) {
                        coordinator.presentFullScreen(.focusTool(.focusMode))
                    }
                }
                .padding()
            }
            .navigationTitle("Tools")
        }
    }
}





