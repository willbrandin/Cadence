import SwiftUI
import AddComponentFlowFeature
import ComposableArchitecture
import Models
import BrandClient
import BikeClient
import ComponentClient
import MaintenanceClient
import Style
import SwiftUIHelpers
import EditBikeFeature
import BikeComponentRowFeature
import ComponentDetailFeature
import UserSettingsFeature

public typealias BikeComponentReducer = Reducer<BikeComponentState, BikeComponentAction, BikeComponentEnvironment>

public struct BikeComponentState: Equatable {
    public init(
        bike: Bike = .yetiMountain,
        isShowing: Bool = false,
        selection: Identified<Component.ID, ComponentDetailState>? = nil,
        isBikeOptionSheetActive: Bool = false,
        isAddComponentFlowNavigationActive: Bool = false,
        addComponentFlowState: AddComponentFlowState? = nil,
        editBikeState: EditBikeState? = nil,
        isEditBikeFlowNavigationActive: Bool = false,
        userSettings: UserSettings
    ) {
        self.bike = bike
        self.isShowing = isShowing
        self.selection = selection
        self.isBikeOptionSheetActive = isBikeOptionSheetActive
        self.isAddComponentFlowNavigationActive = isAddComponentFlowNavigationActive
        self.addComponentFlowState = addComponentFlowState
        self.editBikeState = editBikeState
        self.isEditBikeFlowNavigationActive = isEditBikeFlowNavigationActive
        self.userSettings = userSettings
    }
    
    public var bike: Bike = .yetiMountain
    public var isShowing = false
    public var selection: Identified<Component.ID, ComponentDetailState>?
    public var isBikeOptionSheetActive = false
    public var isAddComponentFlowNavigationActive = false
    public var addComponentFlowState: AddComponentFlowState?
    public var editBikeState: EditBikeState?
    public var isEditBikeFlowNavigationActive = false
    public var userSettings: UserSettings
    
    public var components: IdentifiedArrayOf<Component> {
        get {
            return IdentifiedArrayOf<Component>(uniqueElements: bike.components)
        }
        
        set {
            newValue.forEach { component in
                if let i = bike.components.firstIndex(where: { $0.id == component.id }) {
                    bike.components[i] = component
                } else {
                    bike.components.append(component)
                }
            }
        }
    }
}

public enum BikeComponentAction: Equatable {
    case componentDetail(ComponentDetailAction)
    case setNavigation(selection: UUID?)
    case setBikeOptionSheet(isActive: Bool)
    case addComponentFlow(AddComponentFlowAction)
    case setComponentFlowNavigation(isActive: Bool)
    case deleteOptionSelected
    case editOptionSelected
    case setEditBikeFlowNavigation(isActive: Bool)
    case saveComponentResponse(Result<Bike, BikeClient.Failure>)
    case editBike(EditBikeAction)
}

public struct BikeComponentEnvironment {
    public init(
        bikeClient: BikeClient = .noop,
        brandAPIClient: BrandClient = .mocked,
        componentClient: ComponentClient = .noop,
        maintenanceClient: MaintenanceClient = .noop,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        date: @escaping () -> Date = { Date() },
        uuid: @escaping () -> UUID = { .init() }
    ) {
        self.bikeClient = bikeClient
        self.brandAPIClient = brandAPIClient
        self.componentClient = componentClient
        self.maintenanceClient = maintenanceClient
        self.mainQueue = mainQueue
        self.date = date
        self.uuid = uuid
    }
    
    public var bikeClient: BikeClient = .noop
    public var brandAPIClient: BrandClient = .mocked
    public var componentClient: ComponentClient = .noop
    public var maintenanceClient: MaintenanceClient = .noop
    public var mainQueue: AnySchedulerOf<DispatchQueue> = .main
    public var date: () -> Date = { Date() }
    public var uuid: () -> UUID = { .init() }
}

private let reducer: BikeComponentReducer =
Reducer { state, action, environment in
    switch action {
    case let .setBikeOptionSheet(isActive):
        state.isBikeOptionSheetActive = isActive
        return .none
        
    case let .setNavigation(selection: .some(id)):
        guard let component = state.components[id: id]
        else { return .none }
        
        state.selection = Identified(
            ComponentDetailState(
                component: component,
                bikeComponents: state.bike.components,
                userSettings: state.userSettings
            ),
            id: id
        )
        
        return .none
        
    case .setNavigation(selection: .none):
        if let selectionState = state.selection {
            state.components[id: selectionState.id] = selectionState.value.component
        }
        
        state.selection = nil
        return .none
   
    case let .setComponentFlowNavigation(isActive):
        if isActive {
            state.addComponentFlowState = AddComponentFlowState(bikeId: state.bike.id, userSettings: state.userSettings)
        } else {
            state.addComponentFlowState = nil
        }
        
        state.isAddComponentFlowNavigationActive = isActive
        return .none
        
    case let .addComponentFlow(.flowComplete(component)):
        state.components.append(component)
        return Effect(value: .setComponentFlowNavigation(isActive: false))
        
    case let .saveComponentResponse(result):
        return .none
            
    case .addComponentFlow(.didTapCloseFlow):
        return Effect(value: .setComponentFlowNavigation(isActive: false))
            .eraseToEffect()
        

    case .deleteOptionSelected:
        return environment.bikeClient.delete(state.bike)
                .fireAndForget()
        
    case let .componentDetail(.componentService(.serviceComponentsUpdateResponse(.success(components)))):
        state.components = IdentifiedArrayOf<Component>(uniqueElements: components)
        return .none
        
    case .componentDetail(.delete):
        if let selected = state.selection {
            state.bike.components.removeAll(where: { $0.id == selected.id })
        }
        
        state.selection = nil
        return .none
        
    case .editOptionSelected:
        state.isEditBikeFlowNavigationActive = true
        state.editBikeState = EditBikeState(bike: state.bike, userSettings: state.userSettings)
        
        return .none
        
    case .setEditBikeFlowNavigation(isActive: false) :
        state.isEditBikeFlowNavigationActive = false
        state.editBikeState = nil
        
        return .none
        
    case let .editBike(.bikeSaved(bike)):
        state.bike = bike
        state.isEditBikeFlowNavigationActive = false
        state.editBikeState = nil
        
        return .none

    default:
        return .none
    }
}
 
public let bikeComponentReducer: BikeComponentReducer =
.combine(
    componentDetailReducer
        .pullback(state: \Identified.value, action: .self, environment: { $0 })
        .optional()
        .pullback(
            state: \.selection,
            action: /BikeComponentAction.componentDetail,
            environment: {
                ComponentDetailEnvironment(
                    componentClient: $0.componentClient,
                    maintenanceClient: $0.maintenanceClient,
                    mainQueue: $0.mainQueue,
                    date: $0.date,
                    uuid: $0.uuid
                )
            }
        ),
    addComponentFlowReducer
        .optional()
        .pullback(
            state: \.addComponentFlowState,
            action: /BikeComponentAction.addComponentFlow,
            environment: {
                AddComponentFlowEnvironment(
                    brandClient: $0.brandAPIClient,
                    componentClient: $0.componentClient,
                    mainQueue: $0.mainQueue,
                    date: $0.date,
                    uuid: $0.uuid
                )
            }
        ),
    editBikeReducer
        .optional()
        .pullback(
            state: \.editBikeState,
            action: /BikeComponentAction.editBike,
            environment: {
                EditBikeEnvironment(
                    bikeClient: $0.bikeClient,
                    mainQueue: $0.mainQueue
                )
            }
        ),
    reducer
)

struct BikeComponentComponentRowView: View {
    let store: Store<BikeComponentState, BikeComponentAction>
    let component: Component
    @ObservedObject var viewStore: ViewStore<BikeComponentState, BikeComponentAction>
    
    @Environment(\.colorScheme) var colorScheme

    init(
        store: Store<BikeComponentState, BikeComponentAction>,
        component: Component
    ) {
        self.store = store
        self.component = component
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
        NavigationLink(
          destination: IfLetStore(
            self.store.scope(
              state: \.selection?.value,
              action: BikeComponentAction.componentDetail
            ),
            then: ComponentDetailView.init(store:)
          ),
          tag: component.id,
          selection: viewStore.binding(
            get: \.selection?.id,
            send: BikeComponentAction.setNavigation(selection:)
          )
        ) {
            BikeComponentRow(component: component, distanceUnit: viewStore.userSettings.distanceUnit)
        }
        .background(Color(colorScheme == .light ? .systemBackground : .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
    }
}

struct BikeComponentSection: View {
    let store: Store<BikeComponentState, BikeComponentAction>
    var groupType: ComponentGroup
    @ObservedObject var viewStore: ViewStore<BikeComponentState, BikeComponentAction>
    
    init(
        store: Store<BikeComponentState, BikeComponentAction>,
        groupType: ComponentGroup
    ) {
        self.store = store
        self.groupType = groupType
        self.viewStore = ViewStore(self.store)
    }
    
    var isComponentsEmpty: Bool {
        viewStore.state.components.filter({ $0.componentGroupId == groupType }).isEmpty
    }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                if !isComponentsEmpty {
                    HStack {
                        Text(groupType.title)
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    ForEach(viewStore.state.components.filter({ $0.componentGroupId == groupType })) { component in
                        BikeComponentComponentRowView(store: store, component: component)
                    }
                }
            }
        }
    }
}

public struct BikeComponentListView: View {
    let store: Store<BikeComponentState, BikeComponentAction>
    @ObservedObject var viewStore: ViewStore<BikeComponentState, BikeComponentAction>
    
    @Environment(\.colorScheme) var colorScheme

    public init(
        store: Store<BikeComponentState, BikeComponentAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var emptyComponentsView: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text("Time for gear")
                        .font(.title.bold())
                    
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.title2)
                        .foregroundColor(viewStore.userSettings.accentColor.color)
                    
                    Spacer()
                }
                .padding()
                
                HStack {
                    Text("What's on your bike? Add some gear now or later. Either way let's ride!")
                        .frame(alignment: .leading)
                        .lineSpacing(8)
                        .multilineTextAlignment(.leading)
                        .padding([.horizontal, .bottom])
                }
                
                Button("New Component", action: { viewStore.send(.setComponentFlowNavigation(isActive: true)) })
                    .buttonStyle(PrimaryButtonStyle())
            }
            .background(Color(colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal)
            Spacer()
            Spacer()
        }
    }
    
    public var body: some View {
        ZStack {
            Color(colorScheme == .light ? .secondarySystemBackground : .systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            if viewStore.bike.components.isEmpty {
                emptyComponentsView
            } else {
                ScrollView {
                    ForEach(ComponentGroup.allCases.sorted(by: { $0.title < $1.title })) { type in
                        BikeComponentSection(store: store, groupType: type)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .confirmationDialog(
            "Bike Options",
        isPresented: viewStore.binding(
            get: \.isBikeOptionSheetActive,
            send: BikeComponentAction.setBikeOptionSheet)
        ) {
            Button("Edit Bike", action: { viewStore.send(.editOptionSelected) })
            Button("Delete Bike", role: .destructive, action: { viewStore.send(.deleteOptionSelected) })
        }
        .sheet(
            isPresented: viewStore
                .binding(
                    get: \.isAddComponentFlowNavigationActive,
                    send: BikeComponentAction.setComponentFlowNavigation
                )
                .removeDuplicates()
        ) {
            IfLetStore(
                store.scope(
                    state: \.addComponentFlowState,
                    action: BikeComponentAction.addComponentFlow
                ),
                then: AddComponentFlowRoot.init
            )
        }
        .sheet(
            isPresented: viewStore
                .binding(
                    get: \.isEditBikeFlowNavigationActive,
                    send: BikeComponentAction.setEditBikeFlowNavigation
                )
                .removeDuplicates()
        ) {
            IfLetStore(
                store.scope(
                    state: \.editBikeState,
                    action: BikeComponentAction.editBike
                ),
                then: EditBikeNavigationView.init
            )
        }
        .navigationTitle(viewStore.state.bike.name)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { viewStore.send(.setBikeOptionSheet(isActive: true)) }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.body.bold())
                }
                .foregroundColor(viewStore.userSettings.accentColor.color)
            }
            
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button(action: { viewStore.send(.setComponentFlowNavigation(isActive: true)) }) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .font(.headline)
                            Text("New Component")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(viewStore.userSettings.accentColor.color)

                    Spacer()
                }
            }
        }
    }
}

struct BikeComponentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BikeComponentListView(
                store: Store(
                    initialState: BikeComponentState(
                        bike: .init(
                            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                            name: "YETI 165C",
                            components: [
                                .shimanoSLXBrakes,
                                .shimanoXLTBrakeRotor,
                                .racefaceCogsette,
                                .wtbFrontWheelSet,
                                .yeti165Frame,
                                .racefaceCarbon69Handlebars
                            ],
                            bikeTypeId: .mountain,
                            mileage: .good,
                            maintenances: [],
                            brand: .yeti,
                            rides: []
                        ),
                        userSettings: .init()
                    ),
                    reducer: bikeComponentReducer,
                    environment: BikeComponentEnvironment()
                )
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
