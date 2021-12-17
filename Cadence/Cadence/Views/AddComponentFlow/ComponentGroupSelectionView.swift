import SwiftUI
import ComposableArchitecture
import Models

typealias ComponentGroupSelectionReducer = Reducer<ComponentGroupSelectionState, ComponentGroupSelectionAction, ComponentGroupSelectionEnvironment>

struct ComponentGroupSelectionState: Equatable {
    var selectedComponentType: ComponentGroup? = nil
    var components: [ComponentGroup] = ComponentGroup.allCases
}

enum ComponentGroupSelectionAction: Equatable {
    case didSelect(ComponentGroup)
}

struct ComponentGroupSelectionEnvironment {}

let componentGroupSelectionReducer = ComponentGroupSelectionReducer
{ state, action, environment in
    switch action {
    case let .didSelect(component):
        state.selectedComponentType = component
        return .none
    }
}

struct ComponentGroupSelectionView: View {
    
    let store: Store<ComponentGroupSelectionState, ComponentGroupSelectionAction>
    @ObservedObject var viewStore: ViewStore<ComponentGroupSelectionState, ComponentGroupSelectionAction>
    
    init(
        store: Store<ComponentGroupSelectionState, ComponentGroupSelectionAction>
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
