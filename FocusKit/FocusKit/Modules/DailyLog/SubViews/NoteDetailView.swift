import SwiftUI

struct NoteDetailView: View {
    let note: Note
    @ObservedObject var viewModel: DailyLogViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(note.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(note.content)
                    .font(.body)
                
                if !note.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(note.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                
                Text("Created: \(note.createdAt, style: .date) at \(note.createdAt, style: .time)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    coordinator.presentSheet(.editNote(note))
                }
            }
        }
    }
}

