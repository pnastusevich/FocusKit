
import SwiftUI

struct PuzzleGameView: View {
    @ObservedObject var viewModel: FocusToolsViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var showWinAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Solve the puzzle")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 4), spacing: 4) {
                    ForEach(0..<4) { row in
                        ForEach(0..<4) { col in
                            let value = viewModel.puzzleGrid[row][col]
                            
                            if value == 0 {
                                Color.clear
                                    .frame(height: 70)
                            } else {
                                Button(action: {
                                    if viewModel.movePuzzleTileAndCheckWin(row: row, col: col) {
                                        showWinAlert = true
                                    }
                                }) {
                                    Text("\(value)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 70)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding()
                
                Button(action: {
                    viewModel.initializePuzzle()
                }) {
                    Text("Shuffle")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Puzzle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        coordinator.dismissSheet()
                    }
                }
            }
            .alert("Congratulations!", isPresented: $showWinAlert) {
                Button("New Game") {
                    viewModel.initializePuzzle()
                }
                Button("OK") { }
            } message: {
                Text("You solved the puzzle!")
            }
        }
    }
}
