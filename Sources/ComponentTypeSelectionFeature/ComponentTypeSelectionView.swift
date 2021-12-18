import SwiftUI
import ComposableArchitecture
import Models

public struct ComponentTypeSelectionState: Equatable {
    public init(
        selectedComponentType: ComponentType? = nil,
        components: [ComponentType] = ComponentType.allCases
    ) {
        self.selectedComponentType = selectedComponentType
        self.components = components
    }
    
    public var selectedComponentType: ComponentType? = nil
    public var components: [ComponentType] = ComponentType.allCases
}

public enum ComponentTypeSelectionAction: Equatable {
    case didSelect(ComponentType)
}

public struct ComponentTypeSelectionEnvironment {
    public init() {}
}

public let componentTypeSelectionReducer: Reducer<ComponentTypeSelectionState, ComponentTypeSelectionAction, ComponentTypeSelectionEnvironment> = Reducer { state, action, environment in
    switch action {
    case let .didSelect(component):
        state.selectedComponentType = component
        return .none
    }
}

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
        List(viewStore.components) { component in
            Button(action: { viewStore.send(.didSelect(component)) }) {
                HStack {
                    Text(component.title)
                        .padding(.vertical)
                    Spacer()
                    if component == viewStore.selectedComponentType {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle("Component Type")
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
