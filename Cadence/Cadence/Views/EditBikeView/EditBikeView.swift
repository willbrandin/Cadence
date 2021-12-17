import SwiftUI
import ComposableArchitecture
import Models

typealias EditBikeReducer = Reducer<EditBikeState, EditBikeAction, EditBikeEnvironment>

struct EditBikeState: Equatable {
    var bike: Bike = .yetiMountain
        
    var bikeName: String {
        get {
            return bike.name
        }
        
        set {
            bike.name = newValue
        }
    }
    
    var isSaveBikeRequestInFlight = false
    @BindableState var alert: AlertState<EditBikeAction>?
}

enum EditBikeAction: Equatable, BindableAction {
    case binding(BindingAction<EditBikeState>)
    case updateBikeName(name: String)
    case saveBike
    case saveBikeResponse(Result<Bike, BikeClient.Failure>)
    case bikeSaved(Bike)
    case alertOkayTapped
    case alertDismissed
}

struct EditBikeEnvironment {
    var bikeClient: BikeClient = .mocked
    var mainQueue: AnySchedulerOf<DispatchQueue> = .main
}

let editBikeReducer = EditBikeReducer
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

struct EditBikeNavigationView: View {
    let store: Store<EditBikeState, EditBikeAction>
    
    init(
        store: Store<EditBikeState, EditBikeAction>
    ) {
        self.store = store
    }
    
    var body: some View {
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
