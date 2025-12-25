import SwiftUI
import Combine

@MainActor
final class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme? = nil
    
    private let storageService: StorageServiceProtocol
    private let settingsKey = "app_settings"
    
    init(storageService: StorageServiceProtocol = StorageService()) {
        self.storageService = storageService
        loadTheme()
    }
    
    private func loadTheme() {
        let settings = storageService.load(AppSettings.self, forKey: settingsKey) ?? AppSettings()
        
        switch settings.theme {
        case "light":
            colorScheme = .light
        case "dark":
            colorScheme = .dark
        default:
            colorScheme = nil
        }
    }
    
    func updateTheme(_ theme: String) {
        var settings = storageService.load(AppSettings.self, forKey: settingsKey) ?? AppSettings()
        settings.theme = theme
        storageService.save(settings, forKey: settingsKey)
        loadTheme()
    }
}

