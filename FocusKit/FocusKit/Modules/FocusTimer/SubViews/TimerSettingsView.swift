import SwiftUI
 
struct TimerSettingsView: View {
    @ObservedObject var viewModel: FocusTimerViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var workMinutes: Int = 25
    
    var body: some View {
        Form {
            Section(header: Text("Work Duration")) {
                Stepper("\(workMinutes) minutes", value: $workMinutes, in: 25...50)
                    .onChange(of: workMinutes) { newValue in
                        viewModel.updateWorkDuration(newValue)
                    }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    coordinator.dismissSheet()
                }
            }
        }
        .onAppear {
            workMinutes = Int(viewModel.totalDuration / 60)
        }
    }
}
