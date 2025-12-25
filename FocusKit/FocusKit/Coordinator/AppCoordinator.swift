import SwiftUI
import Combine

enum AppRoute: Hashable, Identifiable {
    case noteDetail(Note)
    case addNote
    case editNote(Note)
    case habitDetail(Habit)
    case addHabit
    case timerSettings
    case profileSettings
    case focusTool(FocusToolType)
    
    var id: Self { self }
}

enum FocusToolType: Hashable {
    case timer
    case puzzle
    case reaction
    case focusMode
}

protocol CoordinatorProtocol: ObservableObject {
    var path: NavigationPath { get set }
    var presentedSheet: AppRoute? { get set }
    var presentedFullScreen: AppRoute? { get set }
    
    func navigate(to route: AppRoute)
    func presentSheet(_ route: AppRoute)
    func presentFullScreen(_ route: AppRoute)
    func dismissSheet()
    func dismissFullScreen()
    func pop()
    func popToRoot()
}

@MainActor
final class AppCoordinator: CoordinatorProtocol {
    @Published var path = NavigationPath()
    @Published var presentedSheet: AppRoute? = nil
    @Published var presentedFullScreen: AppRoute? = nil
    
    func navigate(to route: AppRoute) {
        path.append(route)
        Logger.shared.debug("Navigated to route: \(route)")
    }
    
    func presentSheet(_ route: AppRoute) {
        presentedSheet = route
        Logger.shared.debug("Presented sheet: \(route)")
    }
    
    func presentFullScreen(_ route: AppRoute) {
        presentedFullScreen = route
        Logger.shared.debug("Presented full screen: \(route)")
    }
    
    func dismissSheet() {
        Logger.shared.debug("Dismissed sheet")
        presentedSheet = nil
    }
    
    func dismissFullScreen() {
        Logger.shared.debug("Dismissed full screen")
        presentedFullScreen = nil
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
            Logger.shared.debug("Popped navigation")
        }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
        Logger.shared.debug("Popped to root")
    }
}

