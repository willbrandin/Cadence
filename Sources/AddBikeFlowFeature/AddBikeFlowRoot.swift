import SwiftUI
import BikeClient
import ComposableArchitecture
import ComposableHelpers
import Models
import BrandClient
import BrandListFeature
import SaveNewBikeFeature
import BikeTypeSelectionFeature
import SwiftUIHelpers

public typealias AddBikeFlowReducer = Reducer<AddBikeFlowState, AddBikeFlowAction, AddBikeFlowEnvironment>

public struct AddBikeFlowState: Equatable {
    public init(
        selectedBikeType: BikeType? = nil,
        isBrandNavigationActive: Bool = false,
        brandSelectionState: BrandListState = BrandListState(brandContext: .bikes),
        isSaveBikeNavigationActive: Bool = false,
        saveNewBikeState: SaveNewBikeState? = nil
    ) {
        self.selectedBikeType = selectedBikeType
        self.isBrandNavigationActive = isBrandNavigationActive
        self.brandSelectionState = brandSelectionState
        self.isSaveBikeNavigationActive = isSaveBikeNavigationActive
        self.saveNewBikeState = saveNewBikeState
    }
    
    public var selectedBikeType: BikeType?
    public var isBrandNavigationActive = false
    public var brandSelectionState = BrandListState(brandContext: .bikes)
    public var isSaveBikeNavigationActive = false
    public var saveNewBikeState: SaveNewBikeState?
    
    public var bikeSelectionState: BikeTypeSelectionState {
        get {
            return BikeTypeSelectionState(selectedBikeType: selectedBikeType)
        }
        
        set {
            selectedBikeType = newValue.selectedBikeType
        }
    }
}

public enum AddBikeFlowAction: Equatable {
    case didTapCloseFlow
    case flowComplete(Bike)
    case bikeType(BikeTypeSelectionAction)
    case brandList(BrandListAction)
    case setBrandListNavigation(isActive: Bool)
    case saveBike(SaveNewBikeAction)
    case setNewBikeNavigation(isActive: Bool)
}

public struct AddBikeFlowEnvironment {
    public init(
        brandClient: BrandClient = .mocked,
        bikeClient: BikeClient = .mocked,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        uuid: @escaping () -> UUID = { .init() }
    ) {
        self.brandClient = brandClient
        self.bikeClient = bikeClient
        self.mainQueue = mainQueue
        self.uuid = uuid
    }
    
    var brandClient: BrandClient = .mocked
    var bikeClient: BikeClient = .mocked
    var mainQueue: AnySchedulerOf<DispatchQueue> = .main
    var uuid: () -> UUID = { .init() }
}

private let reducer = AddBikeFlowReducer
{ state, action, environment in
    switch action {
    case let .setBrandListNavigation(isActive):
        state.isBrandNavigationActive = isActive
        return .none
        
    case let .setNewBikeNavigation(isActive):
        state.isSaveBikeNavigationActive = isActive
        return .none
        
    case let .saveBike(.bikeSaved(bike)):
        return Effect(value: AddBikeFlowAction.flowComplete(bike))
            .eraseToEffect()
        
    case .bikeType(.didSelect):
        state.isBrandNavigationActive = true
        return .none
        
    case .brandList(.setSelected):
        state.isSaveBikeNavigationActive = true
        return .none
        
    default:
        return .none
    }
}

public let addBikeFlowReducer: AddBikeFlowReducer =
.combine(
    reducer,
    bikeTypeSelectionReducer
        .pullback(
            state: \.bikeSelectionState,
            action: /AddBikeFlowAction.bikeType,
            environment: { _ in BikeTypeSelectionEnvironment() }
        ),
    brandListReducer
        .pullback(
            state: \.brandSelectionState,
            action: /AddBikeFlowAction.brandList,
            environment: { BrandListEnvironment(brandClient: $0.brandClient, mainQueue: $0.mainQueue) }
        ),
    saveNewBikeReducer
        .optional()
        .pullback(
            state: \.saveNewBikeState,
            action: /AddBikeFlowAction.saveBike,
            environment: {
                SaveNewBikeEnvironment(
                    bikeClient: $0.bikeClient,
                    mainQueue: $0.mainQueue,
                    uuid: $0.uuid
                )
            }
        )
)
.onChange(of: \.brandSelectionState.selectedBrand) { brand, state, _, _ in
    guard let bikeType = state.bikeSelectionState.selectedBikeType,
          let brand = state.brandSelectionState.selectedBrand
    else { return .none }
    
    state.saveNewBikeState = SaveNewBikeState(
        bikeType: bikeType,
        bikeBrand: brand
    )
    
    return .none
}

public struct AddBikeFlowRootView: View {
    
    let store: Store<AddBikeFlowState, AddBikeFlowAction>
    @ObservedObject var viewStore: ViewStore<AddBikeFlowState, AddBikeFlowAction>
    
    public init(
        store: Store<AddBikeFlowState, AddBikeFlowAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
                                                
    public var body: some View {
        NavigationView {
            VStack {
                NavigationLink(isActive: viewStore.binding(
                    get: \.isBrandNavigationActive,
                    send: AddBikeFlowAction.setBrandListNavigation)
                                .removeDuplicates()
                ) {
                    VStack {
                        BrandListView(
                            store: self.store.scope(
                                state: \.brandSelectionState,
                                action: AddBikeFlowAction.brandList
                            )
                        )
                        .navigationTitle("Bike Brand")
                        .interactiveDismissDisabled()
                        
                        NavigationLink(isActive: viewStore.binding(
                            get: \.isSaveBikeNavigationActive,
                            send: AddBikeFlowAction.setNewBikeNavigation)
                                        .removeDuplicates()
                        ) {
                            IfLetStore(
                                self.store.scope(
                                    state: \.saveNewBikeState,
                                    action: AddBikeFlowAction.saveBike
                                ),
                                then: SaveNewBikeView.init
                            )
                            .navigationTitle("Save Bike")
                        } label: {
                            EmptyView()
                        }
                    }
                    
                } label: {
                    EmptyView()
                }
                
                BikeTypeSelectionView(
                    store: store.scope(
                        state: \.bikeSelectionState,
                        action: AddBikeFlowAction.bikeType
                    )
                )
            }
            .navigationTitle("New Bike")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { viewStore.send(.didTapCloseFlow) }) {
                        Image(systemName: "xmark")
                            .font(.body.bold())
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct BikeFlowRootView_Previews: PreviewProvider {
    static var previews: some View {
        AddBikeFlowRootView(
            store: Store(
                initialState: AddBikeFlowState(),
                reducer: addBikeFlowReducer,
                environment: AddBikeFlowEnvironment())
        )
    }
}
