import SwiftUI
import TypeSelectionFeature
import ComposableArchitecture
import CreateComponentFeature
import Models
import BrandClient
import BrandListFeature
import ComponentClient
import World
import UserSettingsFeature

public typealias AddComponentFlowReducer = Reducer<AddComponentFlowState, AddComponentFlowAction, AddComponentFlowEnvironment>

public struct AddComponentFlowState: Equatable {
    public init(
        bikeId: UUID,
        groupSelectionState: ComponentGroupSelectionState = ComponentGroupSelectionState(),
        isTypeSelectionNavigationActive: Bool = false,
        typeSelectionState: ComponentTypeSelectionState = ComponentTypeSelectionState(),
        isBrandNavigationActive: Bool = false,
        brandListState: BrandListState = BrandListState(brandContext: .components, userSettings: .init()),
        isComponentDetailNavigationActive: Bool = false,
        componentDetailState: CreateComponentState? = nil,
        userSettings: UserSettings
    ) {
        self.bikeId = bikeId
        self.groupSelectionState = groupSelectionState
        self.isTypeSelectionNavigationActive = isTypeSelectionNavigationActive
        self.typeSelectionState = typeSelectionState
        self.isBrandNavigationActive = isBrandNavigationActive
        self.brandListState = BrandListState(brandContext: .components, userSettings: userSettings)
        self.isComponentDetailNavigationActive = isComponentDetailNavigationActive
        self.componentDetailState = componentDetailState
        self.userSettings = userSettings
    }
    
    public var bikeId: UUID
    public var groupSelectionState = ComponentGroupSelectionState()
    
    public var isTypeSelectionNavigationActive = false
    public var typeSelectionState = ComponentTypeSelectionState()

    public var isBrandNavigationActive = false
    public var brandListState: BrandListState
    
    public var isComponentDetailNavigationActive = false
    public var componentDetailState: CreateComponentState?
    public var userSettings: UserSettings
}

public enum AddComponentFlowAction: Equatable {
    case didTapCloseFlow
    case flowComplete(Component)
    
    case groupSelection(ComponentGroupSelectionAction)
    case typeSelection(ComponentTypeSelectionAction)
    case brandList(BrandListAction)
    case componentDetail(CreateComponentAction)
    
    case setTypeSelctionNavigation(isActive: Bool)
    case setBrandSelectionNavigation(isActive: Bool)
    case setComponentDetailNavigation(isActive: Bool)
}

public struct AddComponentFlowEnvironment {
    public init(
        brandClient: BrandClient = .mocked,
        componentClient: ComponentClient = .noop,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        date: @escaping () -> Date = Current.date,
        uuid: @escaping () -> UUID = Current.uuid
    ) {
        self.brandClient = brandClient
        self.componentClient = componentClient
        self.mainQueue = mainQueue
        self.date = date
        self.uuid = uuid
    }
    
    var brandClient: BrandClient = .mocked
    var componentClient: ComponentClient = .noop
    var mainQueue: AnySchedulerOf<DispatchQueue> = .main
    var date: () -> Date = Current.date
    var uuid: () -> UUID = Current.uuid
}

private let reducer = AddComponentFlowReducer
{ state, action, environment in
    switch action {
    case let .componentDetail(.componentSaved(component)):
        return Effect(value: AddComponentFlowAction.flowComplete(component))
            .eraseToEffect()
        
    case let .setTypeSelctionNavigation(isActive):
        state.isTypeSelectionNavigationActive = isActive
        return .none
        
    case let .setBrandSelectionNavigation(isActive):
        state.isBrandNavigationActive = isActive
        return .none
        
    case let .setComponentDetailNavigation(isActive):
        state.isComponentDetailNavigationActive = isActive
        return .none
        
    case .groupSelection(.binding(\.$selectedComponentGroupType)):
        state.isTypeSelectionNavigationActive = true
        return .none
        
    case .typeSelection(.binding(\.$selectedComponentType)):
        state.isBrandNavigationActive = true
        return .none
        
    case .brandList(.setSelected):
        state.isComponentDetailNavigationActive = true
        return .none
        
    default:
        return .none
    }
}

public let addComponentFlowReducer: AddComponentFlowReducer =
.combine(
    componentGroupSelectionReducer
        .pullback(
            state: \.groupSelectionState,
            action: /AddComponentFlowAction.groupSelection,
            environment: { _ in ComponentGroupSelectionEnvironment() }
        ),
    componentTypeSelectionReducer
        .pullback(
            state: \.typeSelectionState,
            action: /AddComponentFlowAction.typeSelection,
            environment: { _ in ComponentTypeSelectionEnvironment() }
        ),
    brandListReducer
        .pullback(
            state: \.brandListState,
            action: /AddComponentFlowAction.brandList,
            environment: { BrandListEnvironment(brandClient: $0.brandClient, mainQueue: $0.mainQueue) }
        ),
    addComponentReducer
        .optional()
        .pullback(
            state: \.componentDetailState,
            action: /AddComponentFlowAction.componentDetail,
            environment: {
                CreateComponentEnvironment(
                    componentClient: $0.componentClient,
                    brandClient: $0.brandClient,
                    mainQueue: $0.mainQueue,
                    date: $0.date,
                    uuid: $0.uuid
                )
            }
        ),
    reducer
)
.onChange(of: \.brandListState.selectedBrand) { typeState, state, _, environment in
    guard let group = state.groupSelectionState.selectedComponentGroupType,
          let type = state.typeSelectionState.selectedComponentType,
          let brand = state.brandListState.selectedBrand
    else { return .none }
    
    state.componentDetailState = CreateComponentState(
        date: environment.date(),
        bikeId: state.bikeId,
        brand: brand,
        componentGroup: group,
        componentType: type,
        userSettings: state.userSettings
    )
    return .none
}
.onChange(of: \.componentDetailState?.brandListState?.selectedBrand) { brand, state, _, _ in
    guard let brand = brand else { return .none }
    guard brand != state.brandListState.selectedBrand else { return .none }
    
    state.brandListState.selectedBrand = brand
    return .none
}

private struct ComponentDetailFlow: View {
    let store: Store<AddComponentFlowState, AddComponentFlowAction>
    @ObservedObject var viewStore: ViewStore<AddComponentFlowState, AddComponentFlowAction>
    
    init(
        store: Store<AddComponentFlowState, AddComponentFlowAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
        NavigationLink(
            isActive: viewStore
                .binding(
                    get: \.isComponentDetailNavigationActive,
                    send: AddComponentFlowAction.setComponentDetailNavigation
                )
                .removeDuplicates()
            )
        {
            VStack {
                IfLetStore(
                    self.store.scope(
                        state: \.componentDetailState,
                        action: AddComponentFlowAction.componentDetail
                    ),
                    then: CreateComponentView.init
                )
                .navigationTitle("Save Component")
            }
        } label: {
            EmptyView()
        }
    }
}

private struct BrandSelectionFlow: View {
    let store: Store<AddComponentFlowState, AddComponentFlowAction>
    @ObservedObject var viewStore: ViewStore<AddComponentFlowState, AddComponentFlowAction>
    
    init(
        store: Store<AddComponentFlowState, AddComponentFlowAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
        NavigationLink(
            isActive: viewStore
                .binding(
                    get: \.isBrandNavigationActive,
                    send: AddComponentFlowAction.setBrandSelectionNavigation
                )
                .removeDuplicates()
            )
        {
            VStack {
                BrandListView(
                    store: self.store.scope(
                        state: \.brandListState,
                        action: AddComponentFlowAction.brandList
                    )
                )
                .navigationTitle("Component Brand")
                
                ComponentDetailFlow(store: self.store)
            }
        } label: {
            EmptyView()
        }
    }
}

private struct TypeSelectionFlow: View {
    let store: Store<AddComponentFlowState, AddComponentFlowAction>
    @ObservedObject var viewStore: ViewStore<AddComponentFlowState, AddComponentFlowAction>
    
    init(
        store: Store<AddComponentFlowState, AddComponentFlowAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
        NavigationLink(
            isActive: viewStore
                .binding(
                    get: \.isTypeSelectionNavigationActive,
                    send: AddComponentFlowAction.setTypeSelctionNavigation
                )
                .removeDuplicates()
        )
        {
            VStack {
                ComponentTypeSelectionView(
                    store: self.store.scope(
                        state: \.typeSelectionState,
                        action: AddComponentFlowAction.typeSelection
                    )
                )
                .navigationTitle("Component Type")
                
                BrandSelectionFlow(store: self.store)
            }
        }
        label: {
            EmptyView()
        }
    }
}

public struct AddComponentFlowRoot: View {
    let store: Store<AddComponentFlowState, AddComponentFlowAction>
    @ObservedObject var viewStore: ViewStore<AddComponentFlowState, AddComponentFlowAction>
    
    public init(
        store: Store<AddComponentFlowState, AddComponentFlowAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                TypeSelectionFlow(store: self.store)
                
                ComponentGroupSelectionView(
                    store: store.scope(
                        state: \.groupSelectionState,
                        action: AddComponentFlowAction.groupSelection
                    )
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { viewStore.send(.didTapCloseFlow)} ) {
                            Image(systemName: "xmark")
                                .font(.body.bold())
                        }
                        .foregroundColor(viewStore.userSettings.accentColor.color)
                    }
                }
            }
            .navigationTitle("Component Group")
        }
        .accentColor(viewStore.userSettings.accentColor.color)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AddComponentFlowRoot_Previews: PreviewProvider {
    static var previews: some View {
        AddComponentFlowRoot(
            store: Store(
                initialState: AddComponentFlowState(bikeId: UUID(), userSettings: .init()),
                reducer: addComponentFlowReducer,
                environment: AddComponentFlowEnvironment()
            )
        )
    }
}
