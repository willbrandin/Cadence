import SwiftUI
import ComposableArchitecture
import Models

struct ComponentTypeSelectionState: Equatable {
    var selectedComponentType: ComponentType? = nil
    var components: [ComponentType] = ComponentType.allCases
}

enum ComponentTypeSelectionAction: Equatable {
    case didSelect(ComponentType)
}

struct ComponentTypeSelectionEnvironment {}

let componentTypeSelectionReducer: Reducer<ComponentTypeSelectionState, ComponentTypeSelectionAction, ComponentTypeSelectionEnvironment> = Reducer { state, action, environment in
    switch action {
    case let .didSelect(component):
        state.selectedComponentType = component
        return .none
    }
}

struct ComponentTypeSelectionView: View {
    
    let store: Store<ComponentTypeSelectionState, ComponentTypeSelectionAction>
    @ObservedObject var viewStore: ViewStore<ComponentTypeSelectionState, ComponentTypeSelectionAction>
    
    init(
        store: Store<ComponentTypeSelectionState, ComponentTypeSelectionAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
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
