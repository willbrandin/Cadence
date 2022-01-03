import SwiftUI
import ComposableArchitecture
import Models

extension ComponentType: TypeViewSelectable {}

public typealias ComponentTypeSelectionReducer = Reducer<ComponentTypeSelectionState, ComponentTypeSelectionAction, ComponentTypeSelectionEnvironment>

public struct ComponentTypeSelectionState: Equatable {
    public init(
        selectedComponentType: ComponentType? = nil,
        components: [ComponentType] = ComponentType.allCases
    ) {
        self.selectedComponentType = selectedComponentType
        self.components = components
    }
    
    public var components: [ComponentType]
    @BindableState public var selectedComponentType: ComponentType?
}

public enum ComponentTypeSelectionAction: Equatable, BindableAction {
    case binding(BindingAction<ComponentTypeSelectionState>)
}

public struct ComponentTypeSelectionEnvironment {
    public init() {}
}

public let componentTypeSelectionReducer = ComponentTypeSelectionReducer
{ state, action, environment in
    return .none
}
.binding()

public struct ComponentTypeSelectionView: View {
    
    let store: Store<ComponentTypeSelectionState, ComponentTypeSelectionAction>
    @ObservedObject var viewStore: ViewStore<ComponentTypeSelectionState, ComponentTypeSelectionAction>
    
    public init(
        store: Store<ComponentTypeSelectionState, ComponentTypeSelectionAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        TypeSelectorView(
            title: "Component Type",
            items: viewStore.components,
            selected: viewStore.binding(\.$selectedComponentType)
        )
    }
}

struct ComponentTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ComponentTypeSelectionView(
                    store: Store(
                        initialState: ComponentTypeSelectionState(),
                        reducer: componentTypeSelectionReducer,
                        environment: ComponentTypeSelectionEnvironment()
                    )
                )
                .navigationTitle("Component Type")
                .navigationBarTitleDisplayMode(.inline)
            }
            NavigationView {
                ComponentTypeSelectionView(
                    store: Store(
                        initialState: ComponentTypeSelectionState(
                            components: ComponentType.componentType(in: .drivetrain)
                        ),
                        reducer: componentTypeSelectionReducer,
                        environment: ComponentTypeSelectionEnvironment()
                    )
                )
                    .navigationTitle("Component Type")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .extraExtraLarge)
        }
    }
}
