import SwiftUI

struct AddNoteView: View {
    @ObservedObject var viewModel: DailyLogViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    var editingNote: Note? = nil
    
    @State private var title = ""
    @State private var content = ""
    @State private var tagsText = ""
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Title", text: $title)
            }
            
            Section(header: Text("Content")) {
                TextEditor(text: $content)
                    .frame(minHeight: 200)
            }
            
            Section(header: Text("Tags (comma separated)")) {
                TextField("project, work, idea", text: $tagsText)
            }
        }
        .navigationTitle(editingNote == nil ? "New Note" : "Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    coordinator.dismissSheet()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    let tags = viewModel.parseTags(from: tagsText)
                    
                    if let note = editingNote {
                        var updatedNote = note
                        updatedNote.title = title
                        updatedNote.content = content
                        updatedNote.tags = tags
                        viewModel.updateNote(updatedNote)
                    } else {
                        let note = Note(title: title, content: content, tags: tags)
                        viewModel.addNote(note)
                    }
                    coordinator.dismissSheet()
                }
                .disabled(title.isEmpty || content.isEmpty)
            }
        }
        .onAppear {
            if let note = editingNote {
                title = note.title
                content = note.content
                tagsText = note.tags.joined(separator: ", ")
            }
        }
    }
}

