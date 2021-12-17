import UIKit
import ComposableArchitecture
import FileClient

typealias AppDelegateReducer = Reducer<UserSettings, AppDelegateAction, AppDelegateEnvironment>

enum AppDelegateAction: Equatable {
    case didFinishLaunching
    case userSettingsLoaded(Result<UserSettings, NSError>)
}

struct AppDelegateEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uiUserInterfaceClient: UIUserInterfaceStyleClient
    var fileClient: FileClient
    
    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        uiUserInterfaceClient: UIUserInterfaceStyleClient,
        fileClient: FileClient
    ) {
        self.mainQueue = mainQueue
        self.uiUserInterfaceClient = uiUserInterfaceClient
        self.fileClient = fileClient
    }
    
    #if DEBUG
    static let failing = Self(
        mainQueue: .failing,
        uiUserInterfaceClient: .failing,
        fileClient: .failing
    )
    #endif
}

let appDelegateReducer = AppDelegateReducer
{ state, action, environment in
    switch action {
    case .didFinishLaunching:
        return environment.fileClient.loadUserSettings()
          .map(AppDelegateAction.userSettingsLoaded)
        
    case let .userSettingsLoaded(result):
        state = (try? result.get()) ?? state
        
        // NB: This is necessary because UIKit needs at least one tick of the run loop before we
        //     can set the user interface style.
        return environment.uiUserInterfaceClient.setUserInterfaceStyle(state.colorScheme.userInterfaceStyle)
            .subscribe(on: environment.mainQueue)
            .fireAndForget()
    }
}
