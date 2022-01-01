import SwiftUI
import BikeClient
import ComposableArchitecture
import ComponentClient
import Models
import RideClient
import UserSettingsFeature

public typealias AddRideFlowReducer = Reducer<AddRideFlowState, AddRideFlowAction, AddRideFlowEnvironment>

public struct AddRideFlowState: Equatable {
    public init(
        selectableBikes: [Bike],
        selectedBike: Bike,
        miles: String = "",
        date: Date = Date(),
        userSettings: UserSettings
    ) {
        self.selectableBikes = selectableBikes
        self.selectedBike = selectedBike
        self.miles = miles
        self.date = date
        self.userSettings = userSettings
    }
    
    public var selectableBikes: [Bike]
    public var selectedBike: Bike
    
    @BindableState public var miles: String = ""
    @BindableState public var date: Date = Date()
    public var userSettings: UserSettings
}

public enum AddRideFlowAction: Equatable, BindableAction {
    case binding(BindingAction<AddRideFlowState>)
    case didAppear
    case didTapCloseFlow
    
    case setSelected(bike: Bike)
    
    case saveButtonTapped
    case flowComplete(Ride)
    
    case saveRideResponse(Result<Ride, RideClient.Failure>)
    case updateBikeMileageResponse(Result<Bike, BikeClient.Failure>)
}

public struct AddRideFlowEnvironment {
    public init(
        bikeClient: BikeClient = .noop,
        componentClient: ComponentClient = .noop,
        rideClient: RideClient = .noop,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        date: @escaping () -> Date = { Date() },
        uuid: @escaping () -> UUID = { .init() }
    ) {
        self.bikeClient = bikeClient
        self.componentClient = componentClient
        self.rideClient = rideClient
        self.mainQueue = mainQueue
        self.date = date
        self.uuid = uuid
    }
    
    public var bikeClient: BikeClient = .noop
    public var componentClient: ComponentClient = .noop
    public var rideClient: RideClient = .noop
    public var mainQueue: AnySchedulerOf<DispatchQueue> = .main
    public var date: () -> Date = { Date() }
    public var uuid: () -> UUID = { .init() }
}

public let addRideReducer = AddRideFlowReducer
{ state, action, environment in
    switch action {
    case let .setSelected(bike):
        state.selectedBike = bike
        return .none
        
    case .saveRideResponse(.success):
        guard let rideMiles = Int(state.miles)
        else { return .none }
      
        state.selectedBike.components = state.selectedBike.components.map { component in
            var component = component
            component.mileage.miles = component.mileage.miles + rideMiles
            return component
        }
        
        state.selectedBike.mileage.miles = state.selectedBike.mileage.miles + rideMiles
        
        return environment.bikeClient.update(state.selectedBike)
            .receive(on: environment.mainQueue)
            .catchToEffect(AddRideFlowAction.updateBikeMileageResponse)

    case .saveButtonTapped:
        guard let rideMiles = Int(state.miles)
        else { return .none }
        
        let components = state.selectedBike.components
        let componentIds = components.map { $0.id.uuidString }
        
        let ride = Ride(
            id: environment.uuid(),
            date: state.date,
            distance: rideMiles
        )
        
        return environment.rideClient
            .create(state.selectedBike.id.uuidString, componentIds, ride)
            .receive(on: environment.mainQueue)
            .catchToEffect(AddRideFlowAction.saveRideResponse)
        
    default:
        return .none
    }
}
.binding()

public struct AddRideFlowRootView: View {
    let store: Store<AddRideFlowState, AddRideFlowAction>
    @ObservedObject var viewStore: ViewStore<AddRideFlowState, AddRideFlowAction>
    
    public init(
        store: Store<AddRideFlowState, AddRideFlowAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        List {
            Section {
                ForEach(viewStore.selectableBikes) { bike in
                    Button(action: { viewStore.send(.setSelected(bike: bike))}) {
                        HStack {
                            Text(bike.name)
                            Spacer()
                            Image(systemName: viewStore.selectedBike == bike ? "checkmark.circle.fill" : "circle")
                        }
                    }
                    .foregroundColor(.primary)
                }
            } header: {
                Text("Select Bike")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(.leading, -16)
            } footer: {
                Text("Miles added to your bike will be added to its components as well.")
            }
            .textCase(nil)

            HStack {
                Text("Distance")
                TextField("Miles", text: viewStore.binding(\.$miles), prompt: Text("15"))
                    .keyboardType(.numberPad)
            }
            
            Section {
                DatePicker("Date", selection: viewStore.binding(\.$date), displayedComponents: [.date])
                    .accentColor(viewStore.userSettings.accentColor.color)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: { viewStore.send(.saveButtonTapped) })
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { viewStore.send(.didTapCloseFlow) }) {
                    Image(systemName: "xmark")
                        .font(.body.bold())
                }
                .foregroundColor(viewStore.userSettings.accentColor.color)
            }
        }
        .onAppear {
            viewStore.send(.didAppear)
        }
        .navigationTitle("Add Ride")
    }
}

struct AddRideFlowRootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddRideFlowRootView(
                store: Store(
                    initialState: AddRideFlowState(
                        selectableBikes: [.yetiMountain, .canyonRoad, .specializedMountain],
                        selectedBike: .yetiMountain,
                        miles: "",
                        userSettings: .init()
                    ),
                    reducer: addRideReducer,
                    environment: AddRideFlowEnvironment()
                )
            )
        }
    }
}
