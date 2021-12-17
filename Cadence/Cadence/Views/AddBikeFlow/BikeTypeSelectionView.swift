import SwiftUI
import ComposableArchitecture
import Models

typealias BikeTypeSelectionReducer = Reducer<BikeTypeSelectionState, BikeTypeSelectionAction, BikeTypeSelectionEnvironment>

struct BikeTypeSelectionState: Equatable {
    var selectedBikeType: BikeType? = nil
}

enum BikeTypeSelectionAction: Equatable {
    case removeSelectedType
    case didSelect(BikeType)
}

struct BikeTypeSelectionEnvironment {}

let bikeTypeSelectionReducer: BikeTypeSelectionReducer =
Reducer { state, action, environment in
    switch action {
    case .removeSelectedType:
        state.selectedBikeType = nil
        return .none
        
    case let .didSelect(type):
        state.selectedBikeType = type
        return .none
    }
}

struct BikeTypeSelectionView: View {
    
    let store: Store<BikeTypeSelectionState, BikeTypeSelectionAction>
    @ObservedObject var viewStore: ViewStore<BikeTypeSelectionState, BikeTypeSelectionAction>
    
    init(store: Store<BikeTypeSelectionState, BikeTypeSelectionAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
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
