import SwiftUI
import ComposableArchitecture
import Models

typealias SaveNewBikeReducer = Reducer<SaveNewBikeState, SaveNewBikeAction, SaveNewBikeEnvironment>

struct SaveNewBikeState: Equatable {
    var bikeType: BikeType = BikeType.mountain
    var bikeBrand: Brand = .yeti
    var mileage: Mileage = .base
    var isSaveBikeRequestInFlight = false
    
    @BindableState var bikeName: String = ""
    @BindableState var alert: AlertState<SaveNewBikeAction>?
}

enum SaveNewBikeAction: Equatable, BindableAction {
    case binding(BindingAction<SaveNewBikeState>)
    case saveBike
    case saveBikeResponse(Result<Bike, BikeClient.Failure>)
    case bikeSaved(Bike)
    case alertOkayTapped
    case alertDismissed
}

struct SaveNewBikeEnvironment {
    var bikeClient: BikeClient = .mocked
    var mainQueue: AnySchedulerOf<DispatchQueue> = .main
    var uuid: () -> UUID = Current.uuid
}

let saveNewBikeReducer = SaveNewBikeReducer
{ state, action, environment in
    switch action {
    case let .saveBikeResponse(.success(bike)):
        state.isSaveBikeRequestInFlight = false

        return Effect(value: .bikeSaved(bike))
            .eraseToEffect()
        
    case let .saveBikeResponse(.failure(error)):
        state.isSaveBikeRequestInFlight = false

        return .none
        
    case .saveBike:
        if state.bikeName.isEmpty {
            state.alert = AlertState(
                title: .init("Bike name cannot be empty"),
                dismissButton: .default(.init("Okay"), action: .send(.alertOkayTapped))
            )
            
            return .none
        }
        
        let bike = Bike(
            id: environment.uuid(),
            name: state.bikeName,
            components: [],
            bikeTypeId: state.bikeType,
            mileage: state.mileage,
            maintenances: nil,
            brand: state.bikeBrand,
            rides: []
        )
        
        return environment.bikeClient
            .create(bike)
            .receive(on: environment.mainQueue)
            .catchToEffect(SaveNewBikeAction.saveBikeResponse)
    
    default:
        return .none
    }
}
.binding()

struct SaveNewBikeView: View {
    let store: Store<SaveNewBikeState, SaveNewBikeAction>
    @ObservedObject var viewStore: ViewStore<SaveNewBikeState, SaveNewBikeAction>
    
    init(
        store: Store<SaveNewBikeState, SaveNewBikeAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
        List {
            Section(footer: Text("Give your bike a name.")) {
                TextField(
                    "Bike name field",
                    text: viewStore.binding(\.$bikeName),
                    prompt: Text("Sync'r Carbon")
                )
            }    
            HStack {
                Text("Bike Type")
                Spacer()
                Text(viewStore.bikeType.title)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Brand")
                Spacer()
                Text(viewStore.bikeBrand.brand)
                    .foregroundColor(.secondary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Save", action: { viewStore.send(.saveBike) })
                    .font(.headline.bold())
                    .foregroundColor(.accentColor)
                    .alert(
                        self.store.scope(state: \.alert),
                        dismiss: .alertDismissed
                    )
            }
        }
    }
}

struct SaveNewBikeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SaveNewBikeView(
                store: Store(
                    initialState: SaveNewBikeState(),
                    reducer: saveNewBikeReducer,
                    environment: SaveNewBikeEnvironment()
                )
            )
            .navigationTitle("Bike Details")
        }
    }
}
