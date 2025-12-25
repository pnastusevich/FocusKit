import Foundation

enum GameType {
    case puzzle
    case reaction
}

struct GameScore: Codable, Identifiable {
    let id: UUID
    let gameType: String
    let score: Int
    let date: Date
    
    init(id: UUID = UUID(), gameType: String, score: Int, date: Date = Date()) {
        self.id = id
        self.gameType = gameType
        self.score = score
        self.date = date
    }
}

struct TimerSession: Codable, Identifiable {
    let id: UUID
    let duration: TimeInterval
    let startDate: Date
    let endDate: Date
    
    init(id: UUID = UUID(), duration: TimeInterval, startDate: Date, endDate: Date) {
        self.id = id
        self.duration = duration
        self.startDate = startDate
        self.endDate = endDate
    }
}

