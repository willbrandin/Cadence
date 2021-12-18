import SwiftUI
import ComposableArchitecture
import Models

public typealias BikeTypeSelectionReducer = Reducer<BikeTypeSelectionState, BikeTypeSelectionAction, BikeTypeSelectionEnvironment>

public struct BikeTypeSelectionState: Equatable {
    public init(selectedBikeType: BikeType? = nil) {
        self.selectedBikeType = selectedBikeType
    }
    
    public var selectedBikeType: BikeType? = nil
}

public enum BikeTypeSelectionAction: Equatable {
    case removeSelectedType
    case didSelect(BikeType)
}

public struct BikeTypeSelectionEnvironment {
    public init() {}
}

public let bikeTypeSelectionReducer = BikeTypeSelectionReducer
{ state, action, environment in
    switch action {
    case .removeSelectedType:
        state.selectedBikeType = nil
        return .none
        
    case let .didSelect(type):
        state.selectedBikeType = type
        return .none
    }
}

public struct BikeTypeSelectionView: View {
    
    let store: Store<BikeTypeSelectionState, BikeTypeSelectionAction>
    @ObservedObject var viewStore: ViewStore<BikeTypeSelectionState, BikeTypeSelectionAction>
    
    public init(store: Store<BikeTypeSelectionState, BikeTypeSelectionAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        List(BikeType.allCases) { bike in
            Button(action: { viewStore.send(.didSelect(bike)) }) {
                HStack {
                    Text(bike.title)
                        .padding(.vertical)
                    Spacer()
                    if bike == viewStore.selectedBikeType {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle("Bike Type")
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
            .navigationTitle("Bike Type")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
