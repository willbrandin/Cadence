import SwiftUI
import ComposableArchitecture

struct AppCoreView: View {
    @Environment(\.scenePhase) var scenePhase

    let store: Store<AppCoreState, AppCoreAction>
    @ObservedObject var viewStore: ViewStore<AppCoreState, AppCoreAction>
    
    init(
        store: Store<AppCoreState, AppCoreAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)        
    }
    
    var body: some View {
        NavigationView {
            HomeView(store: store.scope(
                state: \.accountBikesState,
                action: AppCoreAction.home
            ))
                .navigationTitle("Cadence")
        }
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
