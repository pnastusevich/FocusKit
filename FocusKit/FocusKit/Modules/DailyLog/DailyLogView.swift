import SwiftUI

struct DailyLogView: View {
    @StateObject private var viewModel = DailyLogViewModel()
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                
                if !viewModel.allTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            TagButton(title: "All", isSelected: viewModel.selectedTag == nil) {
                                viewModel.selectedTag = nil
                            }
                            
                            ForEach(viewModel.allTags, id: \.self) { tag in
                                TagButton(title: tag, isSelected: viewModel.selectedTag == tag) {
                                    viewModel.selectedTag = viewModel.selectedTag == tag ? nil : tag
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 10)
                }
                
                if viewModel.filteredNotes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "note.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Notes")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Create your first note")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.filteredNotes) { note in
                            Button(action: {
                                coordinator.navigate(to: .noteDetail(note))
                            }) {
                                NoteRowView(note: note)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteNote(viewModel.filteredNotes[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coordinator.presentSheet(.addNote)
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.refreshNotes()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NotesUpdated"))) { _ in
                viewModel.refreshNotes()
            }
            .onChange(of: coordinator.presentedSheet) { newValue in
                if newValue == nil {
                    viewModel.refreshNotes()
                }
            }
        }
    }
}

