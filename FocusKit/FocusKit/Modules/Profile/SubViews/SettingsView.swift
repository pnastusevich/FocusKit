import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var themeManager: ThemeManager
    @State private var localSettings: AppSettings
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        _localSettings = State(initialValue: viewModel.settings)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $localSettings.theme) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .onChange(of: localSettings.theme) { newValue in
                        themeManager.updateTheme(newValue)
                    }
                }
                
                Section(header: Text("Sounds & Notifications")) {
                    Toggle("Sounds", isOn: $localSettings.soundsEnabled)
                    Toggle("Notifications", isOn: $localSettings.notificationsEnabled)
                }
                
                Section(header: Text("Games")) {
                    Picker("Difficulty", selection: $localSettings.gameDifficulty) {
                        Text("Easy").tag("easy")
                        Text("Medium").tag("medium")
                        Text("Hard").tag("hard")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        coordinator.dismissSheet()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.updateSettings(localSettings)
                        coordinator.dismissSheet()
                    }
                }
            }
        }
    }
}
