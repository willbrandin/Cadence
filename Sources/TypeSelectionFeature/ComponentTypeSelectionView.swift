import SwiftUI
import ComposableArchitecture
import Models

extension ComponentType: TypeViewSelectable {}

public typealias ComponentTypeSelectionReducer = Reducer<ComponentTypeSelectionState, ComponentTypeSelectionAction, ComponentTypeSelectionEnvironment>

public struct ComponentTypeSelectionState: Equatable {
    public init(
        selectedComponentType: ComponentType? = nil
    ) {
        self.selectedComponentType = selectedComponentType
    }
    
    @BindableState public var selectedComponentType: ComponentType? = nil
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
            items: ComponentType.allCases,
            selected: viewStore.binding(\.$selectedComponentType)
        )
    }
}

struct ComponentTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
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
    }
}
