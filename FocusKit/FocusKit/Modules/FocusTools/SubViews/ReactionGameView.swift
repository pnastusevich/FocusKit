import SwiftUI
 
struct ReactionGameView: View {
    @ObservedObject var viewModel: FocusToolsViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var gameDuration: TimeInterval = 60
    @State private var timeRemaining: TimeInterval = 60
    @State private var gameTimer: Timer?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if viewModel.isReactionGameActive {
                    GeometryReader { geometry in
                        VStack(spacing: 0) {
                            Text("Score: \(viewModel.reactionScore)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                            
                            Text("Time Left: \(Int(timeRemaining))s")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ZStack {
                                if viewModel.reactionTargetVisible {
                                    Button(action: {
                                        viewModel.tapReactionTarget()
                                    }) {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 2)
                                            )
                                    }
                                    .position(viewModel.reactionTargetPosition)
                                }
                            }
                            .frame(height: geometry.size.height * 0.6)
                            
                            Button(action: {
                                stopGame()
                            }) {
                                Text("Stop")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .cornerRadius(15)
                            }
                            .padding()
                        }
                    }
                } else {
                    VStack(spacing: 30) {
                        Text("Reaction Training")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Tap the red circles as fast as you can!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button(action: {
                            startGame()
                        }) {
                            Text("Start")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(15)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Reaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        stopGame()
                        coordinator.dismissSheet()
                    }
                }
            }
            .onDisappear {
                stopGame()
            }
        }
    }
    
    private func startGame() {
        viewModel.startReactionGame()
        timeRemaining = gameDuration
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopGame()
            }
        }
    }
    
    private func stopGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        viewModel.stopReactionGame()
        if viewModel.reactionScore > 0 {
            viewModel.saveScore(gameType: "reaction", score: viewModel.reactionScore)
        }
    }
}
