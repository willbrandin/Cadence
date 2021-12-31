import SwiftUI
import BikeClient
import ComposableArchitecture
import Models
import UserSettingsFeature

typealias SaveNewBikeReducer = Reducer<SaveNewBikeState, SaveNewBikeAction, SaveNewBikeEnvironment>

public struct SaveNewBikeState: Equatable {
    public init(
        bikeType: BikeType = BikeType.mountain,
        bikeBrand: Brand = .yeti,
        mileage: Mileage = .base,
        isSaveBikeRequestInFlight: Bool = false,
        userSettings: UserSettings
    ) {
        self.bikeType = bikeType
        self.bikeBrand = bikeBrand
        self.mileage = mileage
        self.isSaveBikeRequestInFlight = isSaveBikeRequestInFlight
        self.userSettings = userSettings
    }
    
    public var bikeType: BikeType = BikeType.mountain
    public var bikeBrand: Brand = .yeti
    public var mileage: Mileage = .base
    public var isSaveBikeRequestInFlight = false
    
    @BindableState public var bikeName: String = ""
    @BindableState public var alert: AlertState<SaveNewBikeAction>?
    public var userSettings: UserSettings
}

public enum SaveNewBikeAction: Equatable, BindableAction {
    case binding(BindingAction<SaveNewBikeState>)
    case saveBike
    case saveBikeResponse(Result<Bike, BikeClient.Failure>)
    case bikeSaved(Bike)
    case alertOkayTapped
    case alertDismissed
}

public struct SaveNewBikeEnvironment {
    public init(
        bikeClient: BikeClient = .mocked,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        uuid: @escaping () -> UUID = { .init() }
    ) {
        self.bikeClient = bikeClient
        self.mainQueue = mainQueue
        self.uuid = uuid
    }
    
    public var bikeClient: BikeClient = .mocked
    public var mainQueue: AnySchedulerOf<DispatchQueue> = .main
    public var uuid: () -> UUID = { .init() }
}

public let saveNewBikeReducer = SaveNewBikeReducer
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

public struct SaveNewBikeView: View {
    let store: Store<SaveNewBikeState, SaveNewBikeAction>
    @ObservedObject var viewStore: ViewStore<SaveNewBikeState, SaveNewBikeAction>
    
    public init(
        store: Store<SaveNewBikeState, SaveNewBikeAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
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
                    .foregroundColor(viewStore.userSettings.accentColor.color)
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
                    initialState: SaveNewBikeState(userSettings: .init()),
                    reducer: saveNewBikeReducer,
                    environment: SaveNewBikeEnvironment()
                )
            )
            .navigationTitle("Bike Details")
        }
    }
}
