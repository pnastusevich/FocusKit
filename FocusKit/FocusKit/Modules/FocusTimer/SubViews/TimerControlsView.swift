import SwiftUI

struct TimerControlsView: View {
    @ObservedObject var viewModel: FocusTimerViewModel
    let isSmallScreen: Bool
    let sessionColor: Color
    
    var body: some View {
        VStack(spacing: isSmallScreen ? 5 : 10) {
            HStack(spacing: isSmallScreen ? 10 : 20) {
                if viewModel.isRunning {
                    Button(action: { viewModel.pauseTimer() }) {
                        HStack {
                            Image(systemName: "pause.fill")
                            Text("Pause")
                        }
                        .font(isSmallScreen ? .subheadline : .headline)
                        .foregroundColor(.white)
                        .padding(isSmallScreen ? 10 : 15)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(12)
                    }
                } else {
                    Button(action: { viewModel.startTimer() }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start")
                        }
                        .font(isSmallScreen ? .subheadline : .headline)
                        .foregroundColor(.white)
                        .padding(isSmallScreen ? 10 : 15)
                        .frame(maxWidth: .infinity)
                        .background(sessionColor)
                        .cornerRadius(12)
                    }
                }
                
                Button(action: { viewModel.resetTimer() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(isSmallScreen ? .subheadline : .headline)
                        .foregroundColor(.white)
                        .padding(isSmallScreen ? 10 : 15)
                        .frame(width: isSmallScreen ? 50 : 60)
                        .background(Color.gray)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            Button(action: { viewModel.skipSession() }) {
                Text("Skip Session")
                    .font(isSmallScreen ? .caption : .subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, isSmallScreen ? 5 : 10)
        }
    }
}

