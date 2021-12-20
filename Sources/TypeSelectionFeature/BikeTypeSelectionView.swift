import SwiftUI
import ComposableArchitecture
import Models

extension BikeType: TypeViewSelectable {}

public typealias BikeTypeSelectionReducer = Reducer<BikeTypeSelectionState, BikeTypeSelectionAction, BikeTypeSelectionEnvironment>

public struct BikeTypeSelectionState: Equatable {
    public init(selectedBikeType: BikeType? = nil) {
        self.selectedBikeType = selectedBikeType
    }
    
    @BindableState public var selectedBikeType: BikeType? = nil
}

public enum BikeTypeSelectionAction: Equatable, BindableAction {
    case binding(BindingAction<BikeTypeSelectionState>)
}

public struct BikeTypeSelectionEnvironment {
    public init() {}
}

public let bikeTypeSelectionReducer = BikeTypeSelectionReducer
{ state, action, environment in
    return .none
}
.binding()

public struct BikeTypeSelectionView: View {
    
    let store: Store<BikeTypeSelectionState, BikeTypeSelectionAction>
    @ObservedObject var viewStore: ViewStore<BikeTypeSelectionState, BikeTypeSelectionAction>
    
    public init(store: Store<BikeTypeSelectionState, BikeTypeSelectionAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        TypeSelectorView(
            title: "Bike Type",
            items: BikeType.allCases,
            selected: viewStore.binding(\.$selectedBikeType)
        )
    }
}

struct BikeTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BikeTypeSelectionView(
                store: Store(
                    initialState: BikeTypeSelectionState(),
                    reducer: bikeTypeSelectionReducer,
                    environment: BikeTypeSelectionEnvironment()
                )
            )
        }
    }
}
