import Combine
import SwiftUI

@MainActor
final class FocusToolsViewModel: ObservableObject {
    @Published var timerTime: TimeInterval = 0
    @Published var isTimerRunning: Bool = false
    @Published var puzzleGrid: [[Int]] = []
    @Published var puzzleEmptyPosition: (row: Int, col: Int) = (3, 3)
    @Published var reactionScore: Int = 0
    @Published var reactionTargetVisible: Bool = false
    @Published var reactionTargetPosition: CGPoint = .zero
    @Published var isReactionGameActive: Bool = false
    
    private var timer: Timer?
    private var reactionTimer: Timer?
    private var timerStartDate: Date?
    private let storageService: StorageServiceProtocol
    private let scoresKey = "game_scores"
    private let timerSessionsKey = "timer_sessions"
    
    init(storageService: StorageServiceProtocol = StorageService()) {
        self.storageService = storageService
        initializePuzzle()
    }
    
    func startTimer() {
        if !isTimerRunning {
            timerStartDate = Date()
        }
        isTimerRunning = true
        Logger.shared.info("Stopwatch started")
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.timerTime += 0.1
            }
        }
    }
    
    func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        Logger.shared.info("Stopwatch paused - Time: \(timerTime)")
    }
    
    func resetTimer() {
        if timerTime > 0, let startDate = timerStartDate {
            saveTimerSession(duration: timerTime, startDate: startDate)
        }
        
        pauseTimer()
        timerTime = 0
        timerStartDate = nil
    }
    
    func stopTimer() {
        if timerTime > 0, let startDate = timerStartDate {
            saveTimerSession(duration: timerTime, startDate: startDate)
            Logger.shared.info("Stopwatch stopped - Duration: \(timerTime)s")
        }
        pauseTimer()
        timerStartDate = nil
    }
    
    func getTimerHistory() -> [TimerSession] {
        return storageService.loadArray(TimerSession.self, forKey: timerSessionsKey)
    }
    
    private func saveTimerSession(duration: TimeInterval, startDate: Date) {
        let session = TimerSession(
            duration: duration,
            startDate: startDate,
            endDate: Date()
        )
        var sessions = storageService.loadArray(TimerSession.self, forKey: timerSessionsKey)
        sessions.append(session)
        storageService.saveArray(sessions, forKey: timerSessionsKey)
    }
    
    func initializePuzzle() {
        var numbers = Array(1...15)
        numbers.append(0)
        numbers.shuffle()
        
        puzzleGrid = []
        for i in 0..<4 {
            var row: [Int] = []
            for j in 0..<4 {
                let index = i * 4 + j
                let value = numbers[index]
                row.append(value)
                if value == 0 {
                    puzzleEmptyPosition = (i, j)
                }
            }
            puzzleGrid.append(row)
        }
    }
    
    func movePuzzleTile(row: Int, col: Int) {
        let rowDiff = abs(row - puzzleEmptyPosition.row)
        let colDiff = abs(col - puzzleEmptyPosition.col)
        
        if (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1) {
            let value = puzzleGrid[row][col]
            puzzleGrid[puzzleEmptyPosition.row][puzzleEmptyPosition.col] = value
            puzzleGrid[row][col] = 0
            puzzleEmptyPosition = (row, col)
        }
    }
    
    func movePuzzleTileAndCheckWin(row: Int, col: Int) -> Bool {
        movePuzzleTile(row: row, col: col)
        if isPuzzleSolved() {
            saveScore(gameType: "puzzle", score: 1)
            Logger.shared.info("Puzzle solved!")
            return true
        }
        return false
    }
    
    func isPuzzleSolved() -> Bool {
        var expected = 1
        for i in 0..<4 {
            for j in 0..<4 {
                if i == 3 && j == 3 {
                    if puzzleGrid[i][j] != 0 {
                        return false
                    }
                } else {
                    if puzzleGrid[i][j] != expected {
                        return false
                    }
                    expected += 1
                }
            }
        }
        return true
    }
    
    func startReactionGame() {
        isReactionGameActive = true
        reactionScore = 0
        Logger.shared.info("Reaction game started")
        showNextReactionTarget()
    }
    
    func stopReactionGame() {
        isReactionGameActive = false
        reactionTargetVisible = false
        reactionTimer?.invalidate()
        reactionTimer = nil
        Logger.shared.info("Reaction game stopped - Final score: \(reactionScore)")
    }
    
    func tapReactionTarget() {
        if reactionTargetVisible {
            reactionScore += 1
            reactionTargetVisible = false
            reactionTimer?.invalidate()
            Logger.shared.debug("Reaction target tapped - Score: \(reactionScore)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if self.isReactionGameActive {
                    self.showNextReactionTarget()
                }
            }
        }
    }
    
    private func showNextReactionTarget() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let availableHeight = screenHeight * 0.6
        
        let minX: CGFloat = 20
        let maxX = screenWidth - 50
        
        let minY: CGFloat = 25
        let maxY = availableHeight - 150
        
        reactionTargetPosition = CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: minY...maxY)
        )
        
        reactionTargetVisible = true
        
        reactionTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.reactionTargetVisible = false
                if self?.isReactionGameActive == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self?.showNextReactionTarget()
                    }
                }
            }
        }
    }
    
    func saveScore(gameType: String, score: Int) {
        let score = GameScore(gameType: gameType, score: score)
        var scores = storageService.loadArray(GameScore.self, forKey: scoresKey)
        scores.append(score)
        storageService.saveArray(scores, forKey: scoresKey)
        Logger.shared.info("Game score saved - Type: \(gameType), Score: \(score.score)")
    }
}

