import SwiftUI
import ComposableArchitecture
import Models
import BrandClient
import FileClient

typealias AccountBikesReducer = Reducer<HomeState, HomeAction, HomeEnvironment>

struct HomeState: Equatable {
    var bikes: IdentifiedArrayOf<Bike> = []
    var selectedBike: Identified<Bike.ID, BikeComponentState>?
    var isAccountBikesRequestInFlight = false
    
    var isAddBikeFlowActive = false
    var addBikeFlowState: AddBikeFlowState?
    
    @BindableState var isSettingsSheetActive = false
    var settingsState = SettingsState()
    
    @BindableState var isAddRideSheetActive = false
    var addRideState: AddRideFlowState?
}

enum HomeAction: Equatable, BindableAction {
    case binding(BindingAction<HomeState>)
    case setNavigation(selection: UUID?)
    case bikeComponent(BikeComponentAction)
    case viewLoaded
    case bikesResponse(Result<[Bike], BikeClient.Failure>)
    case setAddBikeFlow(active: Bool)
    case addBikeFlow(AddBikeFlowAction)
    case settings(SettingsAction)
    case addRideTapped
    case addRide(AddRideFlowAction)
}

struct HomeEnvironment {
    var uiApplicationClient: UIApplicationClient
    var uiUserInterfaceStyleClient: UIUserInterfaceStyleClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var fileClient: FileClient
    var userDefaults: UserDefaultsClient
    var bikeClient: BikeClient
    var componentClient: ComponentClient
    var maintenanceClient: MaintenanceClient
    var mileageClient: MileageClient
    var rideClient: RideClient
    var brandAPIClient: BrandClient
    var date: () -> Date
    var uuid: () -> UUID
    var storeKitClient: StoreKitClient
    var shareSheetClient: ShareSheetClient
    var emailClient: EmailClient
    var cloudKitClient: CloudKitClient
}

private let reducer: AccountBikesReducer =
Reducer { state, action, environment in
    switch action {
    case let .bikesResponse(.failure(error)):
        state.isAccountBikesRequestInFlight = false
        return .none
        
    case let .bikesResponse(.success(bikes)):
        state.isAccountBikesRequestInFlight = false
        state.bikes = IdentifiedArrayOf<Bike>(uniqueElements: bikes)
        return .none
        
    case let .setNavigation(selection: .some(id)):
        if let bike = state.bikes[id: id] {
            state.selectedBike = Identified(
                BikeComponentState(
                    bike: bike,
                    distanceUnit: state.settingsState.userSettings.distanceUnit
                ),
                id: id
            )
        }
        
        return .none
        
    case .setNavigation(selection: .none):
        if let selectionState = state.selectedBike {
            state.bikes[id: selectionState.id] = selectionState.value.bike
        }
        
        state.selectedBike = nil
        return .none
        
    case .viewLoaded:
        guard state.bikes.isEmpty
        else { return .none }
        
        state.isAccountBikesRequestInFlight = true
        
        return environment.bikeClient
                .fetch()
                .receive(on: environment.mainQueue)
                .catchToEffect(HomeAction.bikesResponse)

    case let .setAddBikeFlow(isActive):
        state.isAddBikeFlowActive = isActive
        
        if isActive {
            state.addBikeFlowState = AddBikeFlowState()
        } else {
            state.addBikeFlowState = nil
        }
        
        return .none
        
    case let .addBikeFlow(.flowComplete(bike)):
        state.bikes.append(bike)
        return Effect(value: HomeAction.setAddBikeFlow(active: false))
            .eraseToEffect()

    case .addBikeFlow(.didTapCloseFlow):
        return Effect(value: HomeAction.setAddBikeFlow(active: false))
            .eraseToEffect()
        
    case .settings(.binding(\.$distanceUnit)):
        let unit = state.settingsState.userSettings.distanceUnit
        
        var bikes = state.bikes.elements.map { bike -> Bike in
            var bike = bike
            bike.components = bike.components.map { component in
                var component = component
                let miles = Double(component.mileage.miles)
                let updatedMileage = DistanceUnit.convert(to: unit, value: miles)
                component.mileage.miles = Int(updatedMileage)
                return component
            }
            return bike
        }
        
        state.bikes = IdentifiedArrayOf<Bike>(uniqueElements: bikes)
        
        return environment.mileageClient.updateFromUnit(unit)
            .fireAndForget()
        
    case .settings(.didTapClose):
        state.isSettingsSheetActive = false
        return .none
        
    case .bikeComponent(.deleteOptionSelected):
        if let selectionState = state.selectedBike {
            state.bikes.remove(id: selectionState.id)
        }
        
        state.selectedBike = nil
        return .none
        
    case let .addRide(.updateBikeMileageResponse(.success(bike))):
        state.bikes[id: bike.id] = bike
        
        state.isAddRideSheetActive = false
        state.addRideState = nil
        
        return .none
        
    case .addRide(.didTapCloseFlow):
        state.isAddRideSheetActive = false
        state.addRideState = nil
        
        return .none
        
    case .addRideTapped:
        state.isAddRideSheetActive = true
        state.addRideState = AddRideFlowState(
            selectableBikes: state.bikes.elements,
            selectedBike: state.bikes.elements.first!,
            miles: "",
            date: environment.date()
        )
        
        return .none
        
    default:
        return .none
    }
}
.binding()

let homeReducer: AccountBikesReducer =
.combine(
    userSettingsReducer
        .pullback(
            state: \.settingsState,
            action: /HomeAction.settings,
            environment: {
                SettingsEnvironment(
                    applicationClient: $0.uiApplicationClient,
                    uiUserInterfaceStyleClient: $0.uiUserInterfaceStyleClient,
                    fileClient: $0.fileClient,
                    mainQueue: $0.mainQueue,
                    userDefaults: $0.userDefaults,
                    mileageClient: $0.mileageClient,
                    storeKitClient: $0.storeKitClient,
                    shareSheetClient: $0.shareSheetClient,
                    emailClient: $0.emailClient,
                    cloudKitClient: $0.cloudKitClient
                )
            }
        ),
    addBikeFlowReducer
        .optional()
        .pullback(
            state: \.addBikeFlowState,
            action: /HomeAction.addBikeFlow,
            environment: {
                AddBikeFlowEnvironment(
                    brandClient: $0.brandAPIClient,
                    bikeClient: $0.bikeClient,
                    mainQueue: $0.mainQueue,
                    uuid: $0.uuid
                )
            }
        ),
    bikeComponentReducer
        .pullback(state: \Identified.value, action: .self, environment: { $0 })
        .optional()
        .pullback(
            state: \HomeState.selectedBike,
            action: /HomeAction.bikeComponent,
            environment: {
                BikeComponentEnvironment(
                    bikeClient: $0.bikeClient,
                    brandAPIClient: $0.brandAPIClient,
                    componentClient: $0.componentClient,
                    maintenanceClient: $0.maintenanceClient,
                    mainQueue: $0.mainQueue,
                    date: $0.date,
                    uuid: $0.uuid
                )
            }
        ),
    addRideReducer
        .optional()
        .pullback(
            state: \HomeState.addRideState,
            action: /HomeAction.addRide,
            environment: {
                AddRideFlowEnvironment(
                    bikeClient: $0.bikeClient,
                    componentClient: $0.componentClient,
                    rideClient: $0.rideClient,
                    mainQueue: $0.mainQueue,
                    date: $0.date,
                    uuid: $0.uuid
                )
            }
        ),
    reducer
)

struct BikeRowView: View {
    var bike: Bike
    let store: Store<HomeState, HomeAction>
    @ObservedObject var viewStore: ViewStore<HomeState, HomeAction>
    
    @Environment(\.colorScheme) var colorScheme

    init(
        bike: Bike,
        store: Store<HomeState, HomeAction>
    ) {
        self.bike = bike
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
        NavigationLink(
            destination: IfLetStore(
                self.store.scope(
                    state: \.selectedBike?.value,
                    action: HomeAction.bikeComponent
                ),
                then: BikeComponentListView.init(store:)),
            tag: bike.id,
            selection: viewStore.binding(
                get: \.selectedBike?.id,
                send: HomeAction.setNavigation(selection:)
            )
        ) {
            VStack(spacing: 16) {
                HStack {
                    Text(bike.name)
                        .font(.title3.bold())

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    MileageScaleView(mileage: bike.componentMileageAvg)
                    Spacer()
                }
            }
            .foregroundColor(.primary)
        }
        .padding()
        .background(Color(colorScheme == .light ? .systemBackground : .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
    }
}

struct BikeSection: View {
    var bikeType: BikeType
    let store: Store<HomeState, HomeAction>
    @ObservedObject var viewStore: ViewStore<HomeState, HomeAction>

    init(
        bikeType: BikeType,
        store: Store<HomeState, HomeAction>
    ) {
        self.bikeType = bikeType
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
        VStack {
            if !viewStore.bikes.filter({$0.bikeTypeId == bikeType }).isEmpty {
                HStack {
                    Text(bikeType.title)
                        .font(.title2)
                        .bold()
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                ForEach(viewStore.bikes.filter({ $0.bikeTypeId == bikeType })) { bike in
                    BikeRowView(bike: bike, store: store)
                }
            }
        }
    }
}

struct HomeView: View {
    let store: Store<HomeState, HomeAction>
    @ObservedObject var viewStore: ViewStore<HomeState, HomeAction>
    @Environment(\.colorScheme) var colorScheme

    init(
        store: Store<HomeState, HomeAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var emptyCard: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text("New bike day?")
                        .font(.title.bold())
                    
                    Image(systemName: "bicycle")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                    
                    Spacer()
                }
                .padding()
                
                HStack {
                    Text("Create a bike followed by components to track mileage and maintenance.")
                        .frame(alignment: .leading)
                        .lineSpacing(8)
                        .multilineTextAlignment(.leading)
                        .padding([.horizontal, .bottom])
                }
                
                Button("Add Bike", action: { viewStore.send(.setAddBikeFlow(active: true)) })
                    .buttonStyle(PrimaryButtonStyle())
            }
            .background(Color(colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal)
            Spacer()
            Spacer()
        }
    }
    
    var body: some View {
        ZStack {
            Color(colorScheme == .light ? .secondarySystemBackground : .systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            if viewStore.bikes.isEmpty && !viewStore.isAccountBikesRequestInFlight {
                emptyCard
            }
            
            VStack {
                if viewStore.isAccountBikesRequestInFlight {
                    ProgressView()
                } else {
                    ScrollView {
                        ForEach(BikeType.allCases) { type in
                            BikeSection(bikeType: type, store: store)
                        }
                        .padding(.bottom, 32)
                    }
                    .sheet(
                        isPresented: viewStore.binding(
                            get: \.isAddBikeFlowActive,
                            send: HomeAction.setAddBikeFlow)
                            .removeDuplicates()
                    ) {
                        IfLetStore(
                          self.store.scope(
                            state: \.addBikeFlowState,
                            action: HomeAction.addBikeFlow
                          ),
                          then: AddBikeFlowRootView.init
                        )
                    }
                }
            }
            .navigationTitle("Cadence")
            .sheet(
                isPresented: viewStore.binding(\.$isSettingsSheetActive).removeDuplicates()
            ) {
                NavigationView {
                    SettingsView(
                        store: store.scope(
                            state: \.settingsState,
                            action: HomeAction.settings
                        )
                    )
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    #if DEBUG
                    if !viewStore.bikes.isEmpty {
                        Button(action: { viewStore.send(.addRideTapped) }) {
                            Image(systemName: "bicycle")
                        }
                        .sheet(
                            isPresented: viewStore.binding(\.$isAddRideSheetActive).removeDuplicates()
                        ) {
                            IfLetStore(
                              self.store.scope(
                                state: \.addRideState,
                                action: HomeAction.addRide
                              ),
                              then: { store in
                                  NavigationView {
                                      AddRideFlowRootView(store: store)
                                  }
                              }
                            )
                        }
                    }
                    #endif
                    
                    Button(action: { viewStore.send(.set(\.$isSettingsSheetActive, true)) }) {
                        Image(systemName: "gear")
                            .font(.body.bold())
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button(action: { viewStore.send(.setAddBikeFlow(active: true)) }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .font(.headline)
                                Text("Add Bike")
                                    .font(.headline)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .onAppear {
                viewStore.send(.viewLoaded)
            }
        }
    }
}

struct AccountBikesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
          
            NavigationView {
                HomeView(
                    store: Store(
                        initialState: HomeState(bikes: []),
                        reducer: homeReducer,
                        environment: .mocked
                    )
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

extension HomeEnvironment {
    static var mocked: Self {
        Self(
            uiApplicationClient: .noop,
            uiUserInterfaceStyleClient: .noop,
            mainQueue: .main,
            fileClient: .noop,
            userDefaults: .noop,
            bikeClient: .noop,
            componentClient: .noop,
            maintenanceClient: .noop,
            mileageClient: .noop,
            rideClient: .noop,
            brandAPIClient: .mocked,
            date: Current.date,
            uuid: Current.uuid,
            storeKitClient: .noop,
            shareSheetClient: .noop,
            emailClient: .noop,
            cloudKitClient: .noop
        )
    }
}
