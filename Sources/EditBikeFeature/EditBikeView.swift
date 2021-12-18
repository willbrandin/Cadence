import SwiftUI
import ComposableArchitecture
import Models
import BikeClient

public typealias EditBikeReducer = Reducer<EditBikeState, EditBikeAction, EditBikeEnvironment>

public struct EditBikeState: Equatable {
    public init(
        bike: Bike = .yetiMountain,
        isSaveBikeRequestInFlight: Bool = false
    ) {
        self.bike = bike
        self.isSaveBikeRequestInFlight = isSaveBikeRequestInFlight
    }
    
    public var bike: Bike = .yetiMountain
        
    public var bikeName: String {
        get {
            return bike.name
        }
        
        set {
            bike.name = newValue
        }
    }
    
    public var isSaveBikeRequestInFlight = false
    @BindableState public var alert: AlertState<EditBikeAction>?
}

public enum EditBikeAction: Equatable, BindableAction {
    case binding(BindingAction<EditBikeState>)
    case updateBikeName(name: String)
    case saveBike
    case saveBikeResponse(Result<Bike, BikeClient.Failure>)
    case bikeSaved(Bike)
    case alertOkayTapped
    case alertDismissed
}

public struct EditBikeEnvironment {
    public init(
        bikeClient: BikeClient = .mocked,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.bikeClient = bikeClient
        self.mainQueue = mainQueue
    }
    
    public var bikeClient: BikeClient = .mocked
    public var mainQueue: AnySchedulerOf<DispatchQueue> = .main
}

public let editBikeReducer = EditBikeReducer
{ state, action, environment in
    switch action {
    case let .updateBikeName(name):
        state.bikeName = name
        return .none
        
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
        
        return environment.bikeClient
            .update(state.bike)
            .receive(on: environment.mainQueue)
            .catchToEffect(EditBikeAction.saveBikeResponse)
    
    default:
        return .none
    }
}
.binding()

public struct EditBikeNavigationView: View {
    let store: Store<EditBikeState, EditBikeAction>
    
    public init(
        store: Store<EditBikeState, EditBikeAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            EditBikeView(
                store: self.store
            )
            .navigationTitle("Edit Bike")
        }
    }
}

struct EditBikeView: View {
    let store: Store<EditBikeState, EditBikeAction>
    @ObservedObject var viewStore: ViewStore<EditBikeState, EditBikeAction>
    
    init(
        store: Store<EditBikeState, EditBikeAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
        List {
            TextField(
                "Bike name field",
                text: viewStore.binding(get: \.bikeName, send: EditBikeAction.updateBikeName),
                prompt: Text("Bike Name")
            )
            
            HStack {
                Text("Bike Type")
                Spacer()
                Text(viewStore.bike.bikeTypeId.title)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Brand")
                Spacer()
                Text(viewStore.bike.brand.brand)
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

struct EditBikeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditBikeView(
                store: Store(
                    initialState: EditBikeState(),
                    reducer: editBikeReducer,
                    environment: EditBikeEnvironment()
                )
            )
            .navigationTitle("Edit Bike")
        }
    }
}
