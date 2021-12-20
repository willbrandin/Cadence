import SwiftUI
import ComposableArchitecture
import Models

extension ComponentGroup: TypeViewSelectable {}

public typealias ComponentGroupSelectionReducer = Reducer<ComponentGroupSelectionState, ComponentGroupSelectionAction, ComponentGroupSelectionEnvironment>

public struct ComponentGroupSelectionState: Equatable {
    public init(
        selectedComponentType: ComponentGroup? = nil
    ) {
        self.selectedComponentGroupType = selectedComponentGroupType
    }

    @BindableState public var selectedComponentGroupType: ComponentGroup? = nil
}

public enum ComponentGroupSelectionAction: Equatable, BindableAction {
    case binding(BindingAction<ComponentGroupSelectionState>)
}

public struct ComponentGroupSelectionEnvironment {
    public init() {}
}

public let componentGroupSelectionReducer = ComponentGroupSelectionReducer
{ state, action, environment in
    return .none
}
.binding()

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
        TypeSelectorView(
            title: "Component Group",
            items: ComponentGroup.allCases,
            selected: viewStore.binding(\.$selectedComponentGroupType)
        )
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
        }
    }
}
