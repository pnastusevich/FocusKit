import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FocusTimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
                .tag(0)
            
            HabitTrackerView()
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle")
                }
                .tag(1)
            
            DailyLogView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
                .tag(2)
            
            FocusToolsView()
                .tabItem {
                    Label("Tools", systemImage: "wrench.and.screwdriver")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(4)
        }
    }
}
