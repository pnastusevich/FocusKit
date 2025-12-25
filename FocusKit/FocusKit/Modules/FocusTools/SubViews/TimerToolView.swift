import SwiftUI


struct TimerToolView: View {
    @ObservedObject var viewModel: FocusToolsViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text(timeString(from: viewModel.timerTime))
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .monospacedDigit()
                
                HStack(spacing: 20) {
                    if viewModel.isTimerRunning {
                        Button(action: { viewModel.pauseTimer() }) {
                            HStack {
                                Image(systemName: "pause.fill")
                                Text("Pause")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(15)
                        }
                    } else {
                        Button(action: { viewModel.startTimer() }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(15)
                        }
                    }
                    
                    Button(action: { viewModel.resetTimer() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 60)
                            .background(Color.gray)
                            .cornerRadius(15)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Stopwatch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if viewModel.timerTime > 0 {
                            viewModel.stopTimer()
                        }
                        coordinator.dismissSheet()
                    }
                }
            }
            .onDisappear {
                if viewModel.timerTime > 0 {
                    viewModel.stopTimer()
                }
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let milliseconds = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, milliseconds)
    }
}
