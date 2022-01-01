import SwiftUI
import ComposableArchitecture
import OnboardingFeature
import HomeFeature

public struct AppCoreView: View {
    @Environment(\.scenePhase) var scenePhase

    let store: Store<AppCoreState, AppCoreAction>
    @ObservedObject var viewStore: ViewStore<AppCoreState, AppCoreAction>
    
    public init(
        store: Store<AppCoreState, AppCoreAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)        
    }
    
    public var body: some View {
        NavigationView {
            HomeView(store: store.scope(
                state: \.accountBikesState,
                action: AppCoreAction.home
            ))
                .navigationTitle("Cadence")
        }
        .accentColor(viewStore.accountBikesState.settingsState.accentColor.color)
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(
            isPresented: viewStore.binding(
                get: \.isOnboardingSheetActive,
                send: AppCoreAction.setOnboardingSheet
            ).removeDuplicates()
        ) {
            IfLetStore(
                store.scope(
                    state: \.onboardingFlowState,
                    action: AppCoreAction.onboarding
                ),
                then: { store in
                    NavigationView {
                        OnboardingPageView(store: store)
                            .navigationTitle("Cadence")
                    }
                    .accentColor(viewStore.accountBikesState.settingsState.accentColor.color)
                    .navigationViewStyle(StackNavigationViewStyle())
                    .interactiveDismissDisabled()
                }
            )
        }
        .onAppear {
            viewStore.send(.appActive)
        }
    }
}

struct AppCoreView_Previews: PreviewProvider {
    static var previews: some View {
        AppCoreView(
            store: Store(
                initialState: AppCoreState(),
                reducer: appCoreReducer,
                environment: .dev
            )
        )
    }
}
