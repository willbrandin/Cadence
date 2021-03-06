import SwiftUI

import ComposableArchitecture
import Models
import World
import MaintenanceClient
import ComponentClient
import ComponentSelectorFeature
import UserSettingsFeature
//
public typealias ComponentMaintenanceReducer = Reducer<AddComponentMaintenanceState, AddComponentMaintenanceAction, AddComponentMaintenenanceEnvironment>
//
public struct AddComponentMaintenanceState: Equatable {
    public init(
        components: [Component] = [
            .shimanoSLXBrakes,
            .shimanoXLTBrakeRotor,
            .racefaceCogsette,
            .wtbFrontWheelSet,
            .yeti165Frame,
            .racefaceCarbon69Handlebars
        ],
        selectedComponents: [UUID : Component] = [Component.racefaceCarbon69Handlebars.id: .racefaceCarbon69Handlebars],
        description: String = "",
        serviceDate: Date = Current.date(),
        isCustomDate: Bool = false,
        alert: AlertState<AddComponentMaintenanceAction>? = nil,
        isSelectedComponentsNavigationActive: Bool = false,
        userSettings: UserSettings
    ) {
        self.components = components
        self.selectedComponents = selectedComponents
        self.isSelectedComponentsNavigationActive = isSelectedComponentsNavigationActive
        self.userSettings = userSettings
    }

    public var components: [Component]
    public var selectedComponents: [UUID: Component]

    @BindableState public var description: String = ""
    @BindableState public var serviceDate: Date = Current.date()
    @BindableState public var isCustomDate = false
    @BindableState public var alert: AlertState<AddComponentMaintenanceAction>?

    public var isSelectedComponentsNavigationActive = false
    public var userSettings: UserSettings

    public var componentSelectorState: ComponentSelectorState {
        get {
            return ComponentSelectorState(
                components: self.components,
                selectedComponents: self.selectedComponents,
                distanceUnit: self.userSettings.distanceUnit
            )
        }
        set {
            self.selectedComponents = newValue.selectedComponents
        }
    }

    public var serviceDateText: String {
        if Date.isToday(serviceDate) {
            return "Today"
        } else {
            let formatter = Current.dateFormatter(dateStyle: .medium, timeStyle: .none)
            return formatter.string(from: serviceDate)
        }
    }

    fileprivate let mileageAdjustment: Int = 0
}
//
public enum AddComponentMaintenanceAction: Equatable, BindableAction {
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

public struct AddComponentMaintenenanceEnvironment {
    public init(
        maintenanceClient: MaintenanceClient = .noop,
        componentClient: ComponentClient = .noop,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        date: @escaping () -> Date = Current.date,
        uuid: @escaping () -> UUID = Current.uuid
    ) {
        self.maintenanceClient = maintenanceClient
        self.componentClient = componentClient
        self.mainQueue = mainQueue
        self.date = date
        self.uuid = uuid
    }

    public var maintenanceClient: MaintenanceClient = .noop
    public var componentClient: ComponentClient = .noop
    public var mainQueue: AnySchedulerOf<DispatchQueue> = .main
    public var date: () -> Date = Current.date
    public var uuid: () -> UUID = Current.uuid
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
//
    case let .maintenanceSavedResponse(.failure(error)):
        return .none
//
    case .alertOkayTapped, .alertDismissed:
        state.alert = nil
        return .none

    case .binding(\.$isCustomDate):
        if !state.isCustomDate {
            state.serviceDate = environment.date()
        }

        return .none
//
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

public let addComponentMaintenanceReducer = ComponentMaintenanceReducer.combine(
    componentSelectorReducer
        .pullback(
            state: \.componentSelectorState,
            action: CasePath(AddComponentMaintenanceAction.componentSelector),
            environment: { _ in ComponentSelectorEnvironment()}
        ),
    reducer
        .binding()
)

public struct AddComponentMaintenanceView: View {
    let store: Store<AddComponentMaintenanceState, AddComponentMaintenanceAction>
    @ObservedObject var viewStore: ViewStore<AddComponentMaintenanceState, AddComponentMaintenanceAction>

    public init(
        store: Store<AddComponentMaintenanceState, AddComponentMaintenanceAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }

    public var body: some View {
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

                Toggle(isOn: viewStore.binding(\.$isCustomDate).animation(.interactiveSpring())) {
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
                .accentColor(viewStore.userSettings.accentColor.color)
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
                    initialState: AddComponentMaintenanceState(userSettings: .init()),
                    reducer: addComponentMaintenanceReducer,
                    environment: AddComponentMaintenenanceEnvironment())
            )
        }
    }
}
