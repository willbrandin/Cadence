import SwiftUI
import ComposableArchitecture
import Models
import Style
import SwiftUIHelpers
import MileageScaleFeature

typealias OnboardingReducer = Reducer<OnboardingState, OnboardingAction, OnboardingEnvironment>

struct OnboardingState: Equatable {
    var mileageAnimation = MileageAnimationState(width: 250)
    var tabIndex = 0
}

enum OnboardingAction: Equatable {
    case didLogin
    case changeTabIndex(index: Int)
    case mileageAnimation(MileageAnimationAction)
    case onDisappear
    case continueTapped
}

struct OnboardingEnvironment {}

private let reducer = OnboardingReducer
{ state, action, environment in
    switch action {
    case .continueTapped:
        let newIndex = state.tabIndex + 1
        
        if newIndex <= 2 { // Most Tabs
            state.tabIndex = newIndex
            return .none
        }
        
        return .concatenate(
            Effect(value: .mileageAnimation(.cancel))
                                .eraseToEffect(),
            Effect(value: .didLogin)
                .eraseToEffect()
        )
        
    case let .changeTabIndex(index):
        state.tabIndex = index
        return .none
        
    default:
        return .none
    }
}

let onboardingReducer: OnboardingReducer =
.combine(
    mileageAnimationReducer
        .pullback(
            state: \.mileageAnimation,
            action: /OnboardingAction.mileageAnimation,
            environment: { _ in MileageAnimationEnvironment() }
        ),
    reducer
)

struct OnboardingContainerView<Content: View>: View {
    
    @Environment(\.colorScheme) var colorScheme

    var title: String
    var description: String
    var index = 0
    var content: () -> Content
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.title2)
                    .bold()
                
                Text(description)
                    .lineSpacing(8)
            }
            .padding(.bottom)
            
            Spacer()
            
            VStack {
                content()
                .padding()
                .background(Color(colorScheme == .light ? .systemBackground : .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
            }
            
            Spacer()
            Spacer()
            Spacer()
        }
        .padding()
    }
}

struct OnboardingPageView: View {
    let store: Store<OnboardingState, OnboardingAction>
    @ObservedObject var viewStore: ViewStore<OnboardingState, OnboardingAction>
    
    init(
        store: Store<OnboardingState, OnboardingAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            TabView(
                selection: viewStore.binding(
                    get: \.tabIndex,
                    send: OnboardingAction.changeTabIndex
                )
                .removeDuplicates()
            ) {
                VStack {
                    OnboardingContainerView(
                        title: "Add your bikes",
                        description: "Your garage on all your devices. Add mileage and maintenence to get the best performance.",
                        index: 0
                    ) {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Salsa Timberjack")
                                    .font(.title3.bold())
                                
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                MileageScaleView(
                                    mileage: .okay
                                )
                                Spacer()
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                .tag(0)
                
                VStack {
                    OnboardingContainerView(
                        title: "Add Components",
                        description: "Miles from your bike are logged to your components. Always giving you knowledge about it.",
                        index: 1
                    ) {
                        BikeComponentRow(
                            component: .shimanoSLXRearDerailleur,
                            distanceUnit: .miles
                        )
                    }
                }
                .tag(1)
                
                OnboardingContainerView(
                    title: "Track Miles",
                    description: "Miles from your bike are logged to your components. Always giving you knowledge about it.",
                    index: 2
                ) {
                    MileageAnimationView(
                        store: store.scope(
                            state: \.mileageAnimation,
                            action: OnboardingAction.mileageAnimation)
                    )
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .animation(.easeInOut)
            .transition(.slide)
            
            Button(action: { viewStore.send(.didLogin) }) {
                HStack {
                    Text("Ready to roll?")
                        .foregroundColor(.secondary)
                    Text("Let's ride.")
                }
            }
            .font(.callout.bold())
            .padding(.vertical, 8)
            
            Button("Continue", action: {
                viewStore.send(.continueTapped)
            })
            .buttonStyle(PrimaryButtonStyle())
        }
        .onDisappear {
            viewStore.send(.onDisappear)
        }
    }
}

struct OnboardingPageView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPageView(
            store: Store(
                initialState: OnboardingState(),
                reducer: onboardingReducer,
                environment: OnboardingEnvironment()
            )
        )
            .preferredColorScheme(.dark)
    }
}
