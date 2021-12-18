import SwiftUI
import BikeClient
import ComposableArchitecture
import ComponentClient
import Models
import RideClient

typealias AddRideFlowReducer = Reducer<AddRideFlowState, AddRideFlowAction, AddRideFlowEnvironment>

struct AddRideFlowState: Equatable {
    var selectableBikes: [Bike]
    var selectedBike: Bike
    
    @BindableState var miles: String = ""
    @BindableState var date: Date = Date()
}

enum AddRideFlowAction: Equatable, BindableAction {
    case binding(BindingAction<AddRideFlowState>)
    case didAppear
    case didTapCloseFlow
    
    case setSelected(bike: Bike)
    
    case saveButtonTapped
    case flowComplete(Ride)
    
    case saveRideResponse(Result<Ride, RideClient.Failure>)
    case updateBikeMileageResponse(Result<Bike, BikeClient.Failure>)
}

struct AddRideFlowEnvironment {
    var bikeClient: BikeClient = .noop
    var componentClient: ComponentClient = .noop
    var rideClient: RideClient = .noop
    var mainQueue: AnySchedulerOf<DispatchQueue> = .main
    var date: () -> Date = { Date() }
    var uuid: () -> UUID = { .init() }
}

let addRideReducer = AddRideFlowReducer
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

struct AddRideFlowRootView: View {
    let store: Store<AddRideFlowState, AddRideFlowAction>
    @ObservedObject var viewStore: ViewStore<AddRideFlowState, AddRideFlowAction>
    
    init(
        store: Store<AddRideFlowState, AddRideFlowAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
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
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: { viewStore.send(.saveButtonTapped) })
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
                        miles: ""
                    ),
                    reducer: addRideReducer,
                    environment: AddRideFlowEnvironment()
                )
            )
        }
    }
}
