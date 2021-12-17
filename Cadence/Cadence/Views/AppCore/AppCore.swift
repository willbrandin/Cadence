import SwiftUI
import ComposableArchitecture

typealias AppCoreReducer = Reducer<AppCoreState, AppCoreAction, AppCoreEnvironment>

struct AppCoreState: Equatable {
    var isOnboardingSheetActive = false
    var onboardingFlowState:OnboardingState?
    var accountBikesState: HomeState = HomeState()
}

enum AppCoreAction: Equatable {
    case onboarding(OnboardingAction)
    case home(HomeAction)
    case appDelegate(AppDelegateAction)
    case didChangeScenePhase(scenePhase: ScenePhase)
    case setOnboardingSheet(isActive: Bool)
    case appActive
}

private let reducer = AppCoreReducer
{ state, action, environment in
    switch action {
    case .onboarding(.onDisappear):
        state.onboardingFlowState = nil
        return .none
        
    case .appActive:
        if !environment.userDefaults.hasShownFirstLaunchOnboarding {
            state.onboardingFlowState = .init()
            state.isOnboardingSheetActive = true
        }
        
        return .none
            
    case .onboarding(.didLogin):
        state.isOnboardingSheetActive = false
        return environment.userDefaults.setHasShownFirstLaunchOnboarding(true)
            .fireAndForget()
        
    default:
        return .none
    }
}

let appCoreReducer: AppCoreReducer =
.combine(
    appDelegateReducer
        .pullback(
            state: \.accountBikesState.settingsState.userSettings,
            action: /AppCoreAction.appDelegate,
            environment: {
                AppDelegateEnvironment(
                    mainQueue: $0.mainQueue,
                    uiUserInterfaceClient: $0.uiUserInterfaceClient,
                    fileClient: $0.fileClient
                )
            }
        ),
    homeReducer
        .pullback(
            state: \.accountBikesState,
            action: /AppCoreAction.home,
            environment: {
                HomeEnvironment(
                    uiApplicationClient: $0.uiApplicationClient,
                    uiUserInterfaceStyleClient: $0.uiUserInterfaceClient,
                    mainQueue: $0.mainQueue,
                    fileClient: $0.fileClient,
                    userDefaults: $0.userDefaults,
                    bikeClient: $0.bikeClient,
                    componentClient: $0.componentClient,
                    maintenanceClient: $0.maintenanceClient,
                    mileageClient: $0.mileageClient,
                    rideClient: $0.rideClient,
                    brandAPIClient: $0.brandAPIClient,
                    date: $0.date,
                    uuid: $0.uuid,
                    storeKitClient: $0.storeKitClient,
                    shareSheetClient: $0.shareSheetClient,
                    emailClient: $0.emailClient,
                    cloudKitClient: $0.cloudKitClient
                )
            }
        ),
    onboardingReducer
        .optional()
        .pullback(
            state: \.onboardingFlowState,
            action: /AppCoreAction.onboarding,
            environment: { _ in OnboardingEnvironment() }
        ),
    reducer
)
