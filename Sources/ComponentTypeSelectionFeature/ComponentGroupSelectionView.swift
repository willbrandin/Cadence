import SwiftUI
import ComposableArchitecture
import Models

public typealias ComponentGroupSelectionReducer = Reducer<ComponentGroupSelectionState, ComponentGroupSelectionAction, ComponentGroupSelectionEnvironment>

public struct ComponentGroupSelectionState: Equatable {
    public init(
        selectedComponentType: ComponentGroup? = nil,
        components: [ComponentGroup] = ComponentGroup.allCases
    ) {
        self.selectedComponentType = selectedComponentType
        self.components = components
    }
    
    public var selectedComponentType: ComponentGroup? = nil
    public var components: [ComponentGroup] = ComponentGroup.allCases
}

public enum ComponentGroupSelectionAction: Equatable {
    case didSelect(ComponentGroup)
}

public struct ComponentGroupSelectionEnvironment {
    public init() {}
}

public let componentGroupSelectionReducer = ComponentGroupSelectionReducer
{ state, action, environment in
    switch action {
    case let .didSelect(component):
        state.selectedComponentType = component
        return .none
    }
}

public struct ComponentGroupSelectionView: View {
    
    let store: Store<ComponentGroupSelectionState, ComponentGroupSelectionAction>
    @ObservedObject var viewStore: ViewStore<ComponentGroupSelectionState, ComponentGroupSelectionAction>
    
    public init(
        store: Store<ComponentGroupSelectionState, ComponentGroupSelectionAction>
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
        .navigationTitle("Component Group")
    }
}

struct ComponentGroupSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ComponentGroupSelectionView(
                store: Store(
                    initialState: ComponentGroupSelectionState(),
                    reducer: componentGroupSelectionReducer,
                    environment: ComponentGroupSelectionEnvironment()
                )
            )
            .navigationTitle("Component Group")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
