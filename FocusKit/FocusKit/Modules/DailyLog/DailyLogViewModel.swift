import Combine
import SwiftUI

@MainActor
final class DailyLogViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var selectedTag: String? = nil
    @Published var searchText: String = ""
    
    private let storageService: StorageServiceProtocol
    private let notesKey = "notes"
    
    init(storageService: StorageServiceProtocol = StorageService()) {
        self.storageService = storageService
        loadNotes()
    }
    
    var allTags: [String] {
        Array(Set(notes.flatMap { $0.tags })).sorted()
    }
    
    var filteredNotes: [Note] {
        var filtered = notes
        
        if let tag = selectedTag {
            filtered = filtered.filter { $0.tags.contains(tag) }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.createdAt > $1.createdAt }
    }
    
    func addNote(_ note: Note) {
        notes.append(note)
        saveNotes()
        Logger.shared.info("Note added: \(note.title), Tags: \(note.tags.joined(separator: ", "))")
        NotificationCenter.default.post(name: NSNotification.Name("NotesUpdated"), object: nil)
    }
    
    func refreshNotes() {
        loadNotes()
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            var updatedNote = note
            updatedNote.updatedAt = Date()
            notes[index] = updatedNote
            saveNotes()
            Logger.shared.info("Note updated: \(note.title)")
            NotificationCenter.default.post(name: NSNotification.Name("NotesUpdated"), object: nil)
        } else {
            Logger.shared.warning("Failed to update note: \(note.title) - not found")
        }
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
        Logger.shared.info("Note deleted: \(note.title)")
    }
    
    func parseTags(from text: String) -> [String] {
        return text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    private func loadNotes() {
        notes = storageService.loadArray(Note.self, forKey: notesKey)
    }
    
    private func saveNotes() {
        storageService.saveArray(notes, forKey: notesKey)
    }
}

