
import SwiftUI

struct FocusModeView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var focusText: String = ""
    @State private var pulseScale: CGFloat = 1.0
    @State private var textOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        coordinator.dismissFullScreen()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding()
                    
                    Spacer()
                }
                
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .scaleEffect(pulseScale)
                            .opacity(2.0 - pulseScale)
                        
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .scaleEffect(pulseScale * 0.8)
                            .opacity(1.5 - pulseScale * 0.75)
                        
                        Image(systemName: "eye.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 40)
                    
                    Text("Focus Mode")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(textOpacity))
                }
                .frame(height: 200)
                
                TextEditor(text: $focusText)
                    .font(.system(size: 24, design: .monospaced))
                    .foregroundColor(.white)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .padding()
                    .opacity(textOpacity)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                textOpacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.3
            }
        }
    }
}

