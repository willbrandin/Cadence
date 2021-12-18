import SwiftUI
import ComposableArchitecture
import Models
import World
import MaintenanceClient
import ComponentClient

typealias ComponentMaintenanceReducer = Reducer<AddComponentMaintenanceState, AddComponentMaintenanceAction, AddComponentMaintenenanceEnvironment>

struct AddComponentMaintenanceState: Equatable {
    var components: [Component] = [
        .shimanoSLXBrakes,
        .shimanoXLTBrakeRotor,
        .racefaceCogsette,
        .wtbFrontWheelSet,
        .yeti165Frame,
        .racefaceCarbon69Handlebars
    ]
    
    var selectedComponents: [UUID: Component] = [Component.racefaceCarbon69Handlebars.id: .racefaceCarbon69Handlebars]
    
    @BindableState var description: String = ""
    @BindableState var serviceDate: Date = Current.date()
    @BindableState var isCustomDate = false
    @BindableState var alert: AlertState<AddComponentMaintenanceAction>?

    var isSelectedComponentsNavigationActive = false
    var distanceUnit: DistanceUnit = .miles
    
    var componentSelectorState: ComponentSelectorState {
        get {
            return ComponentSelectorState(
                components: self.components,
                selectedComponents: self.selectedComponents,
                distanceUnit: self.distanceUnit
            )
        }
        set {
            self.selectedComponents = newValue.selectedComponents
        }
    }
    
    var serviceDateText: String {
        if Date.isToday(serviceDate) {
            return "Today"
        } else {
            let formatter = Current.dateFormatter(dateStyle: .medium, timeStyle: .none)
            return formatter.string(from: serviceDate)
        }
    }
    
    fileprivate let mileageAdjustment: Int = 0
}

enum AddComponentMaintenanceAction: Equatable, BindableAction {
    case binding(BindingAction<AddComponentMaintenanceState>)
    case didSelect(component: Component)
    case setSelectComponentsNavigationActive(isActive: Bool)
    case componentSelector(ComponentSelectorAction)
    case didTapSave
    case alertOkayTapped
    case alertDismissed
    case maintenanceSavedResponse(Result<Maintenance, MaintenanceClient.Failure>)
    case serviceComponentsUpdateResponse(Result<[Component], ComponentClient.Failure>)
}

struct AddComponentMaintenenanceEnvironment {
    var maintenanceClient: MaintenanceClient = .noop
    var componentClient: ComponentClient = .noop
    var mainQueue: AnySchedulerOf<DispatchQueue> = .main
    var date: () -> Date = Current.date
    var uuid: () -> UUID = Current.uuid
}

private let reducer = ComponentMaintenanceReducer
{ state, action, environment in
    switch action {
    case let .maintenanceSavedResponse(.success(maintenance)):
        var selectedComponents: [Component] = state.selectedComponents.values.map { $0 }

        let properties: [AnyHashable: Any] = [
            "miles": NSNumber(value: state.mileageAdjustment)
        ]
        
        state.selectedComponents.keys.forEach {
            var component = state.selectedComponents[$0]!
            component.mileage.miles = state.mileageAdjustment
            state.selectedComponents[$0] = component
        }
        
        return environment.componentClient.batchUpdate(properties, selectedComponents)
            .receive(on: environment.mainQueue)
            .catchToEffect(AddComponentMaintenanceAction.serviceComponentsUpdateResponse)
        
    case let .maintenanceSavedResponse(.failure(error)):
        return .none
        
    case .alertOkayTapped, .alertDismissed:
        state.alert = nil
        return .none
        
    case .binding(.set(\.$isCustomDate, false)):
        state.serviceDate = environment.date()
        return .none
        
    case .binding(\.$serviceDate):
        // If we are locking to today's date, do not allow the state to change.
        if !state.isCustomDate {
            state.serviceDate = environment.date()
        }
        
        return .none
        
    case .didTapSave:
        if state.selectedComponents.isEmpty {
            state.alert = AlertState(
                title: .init("No component selected"),
                message: nil,
                dismissButton: .default(.init("Okay"), action: .send(.alertOkayTapped))
            )
            
            return .none
        } else if state.description.isEmpty {
            state.alert = AlertState(
                title: .init("Description is empty"),
                message: nil,
                dismissButton: .default(.init("Okay"), action: .send(.alertOkayTapped))
            )
            
            return .none
        } else {
            let newMaintenance = Maintenance(
                id: environment.uuid(),
                description: state.description,
                serviceDate: state.serviceDate
            )
            
            state.selectedComponents.keys.forEach {
                var component = state.selectedComponents[$0]!
                component.maintenances.append(newMaintenance)
                state.selectedComponents[$0] = component
            }
            
            return environment.maintenanceClient
                .create(
                    state.selectedComponents.keys.map({ $0.uuidString }),
                    newMaintenance
                )
                .receive(on: environment.mainQueue)
                .catchToEffect(AddComponentMaintenanceAction.maintenanceSavedResponse)
        }
        
    case let .setSelectComponentsNavigationActive(isActive):
        state.isSelectedComponentsNavigationActive = isActive
        return .none
        
    default:
        return .none
    }
}
.binding()

let addComponentMaintenanceReducer = ComponentMaintenanceReducer.combine(
    componentSelectorReducer
        .pullback(
            state: \.componentSelectorState,
            action: /AddComponentMaintenanceAction.componentSelector,
            environment: { _ in ComponentSelectorEnvironment()}
        ),
    reducer
)

struct AddComponentMaintenanceView: View {
    let store: Store<AddComponentMaintenanceState, AddComponentMaintenanceAction>
    @ObservedObject var viewStore: ViewStore<AddComponentMaintenanceState, AddComponentMaintenanceAction>
    
    init(
        store: Store<AddComponentMaintenanceState, AddComponentMaintenanceAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Description")
                        .font(.headline)
                    TextField("Description", text: viewStore.binding(\.$description), prompt: Text("Brake Bleed"))
                }
            }
            
            Section(
                footer: Text("Some maintenance affects multiple components. Select all that may be affected.")
            ) {
                NavigationLink(
                    isActive: viewStore.binding(
                        get: \.isSelectedComponentsNavigationActive,
                        send: AddComponentMaintenanceAction.setSelectComponentsNavigationActive
                    )
                ) {
                    ComponentSelectorView(
                        store: store.scope(
                            state: \.componentSelectorState,
                            action: AddComponentMaintenanceAction.componentSelector
                        )
                    )
                } label: {
                    HStack {
                        Text("Affected Components")
                        Spacer()
                        Text("\(viewStore.selectedComponents.keys.count)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            VStack(spacing: 0) {
                
                Toggle(isOn: viewStore.binding(\.$isCustomDate)) {
                    VStack(alignment: .leading) {
                        Text("Date")
                        Text(viewStore.serviceDateText)
                            .font(.caption)
                    }
                }
               
            }
            
            if viewStore.isCustomDate {
                DatePicker(
                    "Date serviced",
                    selection: viewStore.binding(\.$serviceDate),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
            }
        }
        .navigationTitle("Add Service")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: { viewStore.send(.didTapSave) })
                    .alert(
                        self.store.scope(state: \.alert),
                        dismiss: .alertDismissed
                    )
            }
        }
    }
}

struct AddComponentMaintenanceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddComponentMaintenanceView(
                store: Store(
                    initialState: AddComponentMaintenanceState(),
                    reducer: addComponentMaintenanceReducer,
                    environment: AddComponentMaintenenanceEnvironment())
            )
        }
    }
}
