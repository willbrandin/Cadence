import SwiftUI
import ComposableArchitecture
import ComponentClient
import MaintenanceClient
import Models
import Style
import SwiftUIHelpers

typealias ComponentDetailReducer = Reducer<ComponentDetailState, ComponentDetailAction, ComponentDetailEnvironment>

struct ComponentDetailState: Equatable {
    var component: Component = .shimanoSLXBrakes
    var bikeComponents: [Component] = [.shimanoSLXBrakes, .shimanoXLTBrakeRotor, .shimanoSLXRearDerailleur]
    var isShowingOptions: Bool = false
    
    var isAddComponentServiceNavigationActive = false
    var addComponentServiceState: AddComponentMaintenanceState?
    var distanceUnit: DistanceUnit = .miles
}

enum ComponentDetailAction: Equatable {
    case toggleShowOptions(Bool)
    case replace
    case delete
    case edit
    
    case componentService(AddComponentMaintenanceAction)
    case setComponentServiceNavigation(isActive: Bool)
}

struct ComponentDetailEnvironment {
    var componentClient: ComponentClient
    var maintenanceClient: MaintenanceClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var date: () -> Date
    var uuid: () -> UUID
}

private let reducer = ComponentDetailReducer
{ state, action, environment in
    switch action {
    case let .componentService(.serviceComponentsUpdateResponse(.success(components))):
        if let updatedComponent = components.first(where: { $0.id == state.component.id }) {
            state.component = updatedComponent
        }
        
        state.bikeComponents = state.bikeComponents.map { bikeComponent in
            var bikeComponent = bikeComponent
            
            components.forEach { component in
                if component.id == bikeComponent.id {
                    bikeComponent.mileage = component.mileage
                }
            }
            
            return bikeComponent
        }
        
        return Effect(value: .setComponentServiceNavigation(isActive: false))
            .eraseToEffect()
        
    case let .setComponentServiceNavigation(isActive):
        state.isAddComponentServiceNavigationActive = isActive
        if isActive {
            state.addComponentServiceState = AddComponentMaintenanceState(
                components: state.bikeComponents,
                selectedComponents: [
                    state.component.id : state.component
                ],
                distanceUnit: state.distanceUnit
            )
        } else {
            state.addComponentServiceState = nil
        }
        
        return .none
  
    case let .toggleShowOptions(isShowing):
        state.isShowingOptions = isShowing
        return .none
        
    case .delete:
        return environment.componentClient.delete(state.component)
            .fireAndForget()
        
    default:
        return .none
    }
}

let componentDetailReducer: ComponentDetailReducer = .combine(
    addComponentMaintenanceReducer
        .optional()
        .pullback(
            state: \.addComponentServiceState,
            action: /ComponentDetailAction.componentService,
            environment: {
                AddComponentMaintenenanceEnvironment(
                    maintenanceClient: $0.maintenanceClient,
                    componentClient: $0.componentClient,
                    mainQueue: $0.mainQueue,
                    date: $0.date,
                    uuid: $0.uuid
                )
            }
        ),
    reducer
)

struct ComponentDetailTitleDetailView<Content: View>: View {
    var title: String
    var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.subheadline)
                .foregroundColor(.secondary)
            content()
        }
    }
}

struct ComponentDetailCardView: View {
    var component: Component
    var distanceUnit: DistanceUnit
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 16) {
                    ComponentDetailTitleDetailView(title: "Make") {
                        Text(component.brand.brand)
                            .font(.headline)
                    }
                    
                    ComponentDetailTitleDetailView(title: "Date Added") {
                        Text(component.addedToBikeDateText)
                            .font(.headline)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    ComponentDetailTitleDetailView(title: "Model") {
                        Text(component.model ?? "n/a")
                            .font(.headline)
                    }
                    
                    ComponentDetailTitleDetailView(title: "Mileage Alert") {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(component.mileage.recommendedMiles)")
                                .font(.headline)

                            Text(distanceUnit.title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.trailing)
            }
            
            Divider()

            HStack {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(component.mileage.miles)")
                        .font(.title2)
                        .bold()
                    Text(distanceUnit.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
                VStack {
                    MileageScaleView(mileage: component.mileage)
                }
            }
        }
        .padding()
        .background(Color(colorScheme == .light ? .systemBackground : .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding()
    }
}

struct MaintenanceSectionView: View {
    var services: [Maintenance] = []
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            ForEach(services.sorted(by: { $0.serviceDate > $1.serviceDate })) { service in
                VStack {
                    HStack {
                        Text(service.description ?? "Maintenance")
                            .font(.headline)
                        Spacer()
                        Text(service.serviceDateString)
                            .font(.caption2.bold())
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(colorScheme == .light ? .systemBackground : .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
            }
        }
    }
}

struct ComponentDetailView: View {
    let store: Store<ComponentDetailState, ComponentDetailAction>
    @ObservedObject var viewStore: ViewStore<ComponentDetailState, ComponentDetailAction>
    @Environment(\.colorScheme) var colorScheme

    init(
        store: Store<ComponentDetailState, ComponentDetailAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
        ScrollView {
            ComponentDetailCardView(component: viewStore.component, distanceUnit: viewStore.distanceUnit)
            
            NavigationLink(
                "Add Service",
                isActive: viewStore.binding(
                    get: \.isAddComponentServiceNavigationActive,
                    send: ComponentDetailAction.setComponentServiceNavigation
                ).removeDuplicates(),
                destination: {
                    IfLetStore(
                        store.scope(
                            state: \.addComponentServiceState,
                            action: ComponentDetailAction.componentService
                        ),
                        then: AddComponentMaintenanceView.init(store:)
                    )
                })
                .buttonStyle(PrimaryButtonStyle())

            HStack {
                Text("History")
                    .font(.title2)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            if viewStore.component.maintenances.isEmpty {
                Text("Add Service to see maintenance history.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                MaintenanceSectionView(services: viewStore.component.maintenances)
            }
            
        }
        .background(Color(colorScheme == .light ? .secondarySystemBackground : .systemBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewStore.send(.toggleShowOptions(true)) }) {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog(
            "Component Options",
            isPresented: viewStore.binding(get: \.isShowingOptions, send: ComponentDetailAction.toggleShowOptions)) {
                Button("Edit Component", action: { viewStore.send(.edit) })
                Button("Delete Component", role: .destructive, action: { viewStore.send(.delete) })
        }
        .navigationTitle(viewStore.component.cellTitle)
    }
}

struct ComponentDetailView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            NavigationView {
                ComponentDetailView(
                    store: Store(
                        initialState: ComponentDetailState(component: .yeti165Frame_WithMaintenance),
                        reducer: componentDetailReducer,
                        environment: .mocked
                    )
                )
            }
            .preferredColorScheme(.dark)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

extension ComponentDetailEnvironment {
    static var mocked: Self {
        Self(
            componentClient: .noop,
            maintenanceClient: .noop,
            mainQueue: .main,
            date: { Date() },
            uuid: { .init() }
        )
    }
}
