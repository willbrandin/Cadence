import AddCustomBrandFeature
import Foundation
import SwiftUI
import ComposableArchitecture
import BrandClient
import Models
import UserSettingsFeature

typealias BrandListReducer = Reducer<BrandListState, BrandListAction, BrandListEnvironment>

public enum BrandListContext: Int, Equatable {
    case bikes = 1
    case components
    case both
}

public struct BrandListState: Equatable {
    public init(
        brandContext: BrandListContext = .both,
        brands: [Brand] = [],
        recentBrands: [Brand] = [],
        userBrands: [Brand] = [],
        filteredBrands: [Brand] = [],
        isBrandRequestInFlight: Bool = false,
        selectedBrand: Brand? = nil,
        isUserBrandRequestInFlight: Bool = false,
        userSettings: UserSettings = .init(),
        addBrandState: AddBrandState = .init(),
        isAddBrandNavigationActive: Bool = false
    ) {
        self.brandContext = brandContext
        self.brands = brands
        self.recentBrands = recentBrands
        self.userBrands = userBrands
        self.filteredBrands = filteredBrands
        self.filterQuery = ""
        self.isBrandRequestInFlight = isBrandRequestInFlight
        self.selectedBrand = selectedBrand
        self.isUserBrandRequestInFlight = isUserBrandRequestInFlight
        self.userSettings = userSettings
        self.addBrandState = addBrandState
        self.isAddBrandNavigationActive = isAddBrandNavigationActive
    }
    
    public var brandContext: BrandListContext
    public var brands: [Brand]
    public var recentBrands: [Brand]
    public var userBrands: [Brand]
    public var filteredBrands: [Brand]
    @BindableState public var filterQuery: String
    public var isBrandRequestInFlight: Bool
    public var isUserBrandRequestInFlight: Bool
    public var selectedBrand: Brand?
    public var userSettings: UserSettings
    public var addBrandState: AddBrandState
    @BindableState public var isAddBrandNavigationActive: Bool
}

public enum BrandListAction: Equatable, BindableAction {
    case binding(BindingAction<BrandListState>)
    case setSelected(brand: Brand)
    case viewLoaded
    case brandsLoaded([Brand])
    case userBrandsResponse(Result<[Brand], BrandClient.Failure>)
    case addBrandAction(AddBrandAction)
    case addBrandButtonTapped
    case addBrandClosedTapped
}

public struct BrandListEnvironment {
    public init(
        brandClient: BrandClient = .mocked,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.brandClient = brandClient
        self.mainQueue = mainQueue
    }
    
    public var brandClient: BrandClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>
}

private let reducer = BrandListReducer
{ state, action, environment in
    switch action {
    case let .setSelected(brand):
        state.selectedBrand = brand
        return .none

    case .addBrandButtonTapped:
        state.isAddBrandNavigationActive = true
        return .none
        
    case .viewLoaded:
        guard state.brands.isEmpty
        else { return .none }
        
        state.isBrandRequestInFlight = true
        state.isUserBrandRequestInFlight = true
        
        return .merge(
            environment.brandClient
                .requestBrands()
                .receive(on: environment.mainQueue)
                .map(BrandListAction.brandsLoaded)
                .eraseToEffect(),
            environment.brandClient
                .requestUserBrands()
                .receive(on: environment.mainQueue)
                .catchToEffect(BrandListAction.userBrandsResponse)
        )
        
    case let .userBrandsResponse(.success(brands)):
        state.isUserBrandRequestInFlight = false
        
        if state.brandContext == .bikes {
            state.userBrands = brands.filter { !$0.isComponentManufacturerOnly }
        } else {
            state.userBrands = brands
        }

        return .none
        
    case let .userBrandsResponse(.failure(error)):
        state.isUserBrandRequestInFlight = false
        return .none
        
    case let .brandsLoaded(brands):
        state.isBrandRequestInFlight = false
        
        // For now, do not filter when showing components
        if state.brandContext == .bikes {
            state.brands = brands.filter { !$0.isComponentManufacturerOnly }
        } else {
            state.brands = brands
        }
        
        state.filteredBrands = state.brands
        return .none
        
    case .binding(\.$filterQuery):
        if !state.filterQuery.isEmpty {
            state.filteredBrands = state.brands.filter { $0.brand.lowercased().contains(state.filterQuery.lowercased()) }
        } else {
            state.filteredBrands = state.brands
        }
        return .none
     
    case .binding:
        return .none
        
    case let .addBrandAction(.didAddBrand(brand)):
        state.userBrands.append(brand)
        state.isAddBrandNavigationActive = false
        state.selectedBrand = brand
        
        return .none
        
    case .addBrandAction(.didTapClose), .addBrandClosedTapped:
        state.isAddBrandNavigationActive = false
        return .none
    
    case .addBrandAction:
        return .none
    }
}
.binding()

public let brandListReducer = BrandListReducer
.combine(
    addBrandReducer
        .pullback(
            state: \BrandListState.addBrandState,
            action: /BrandListAction.addBrandAction,
            environment: {
                AddBrandEnvironment(
                    brandClient: $0.brandClient,
                    mainQueue: $0.mainQueue
                )
            }
        ),
    reducer
)

public struct BrandListView: View {
    @Environment(\.colorScheme) var colorScheme

    let store: Store<BrandListState, BrandListAction>
    @ObservedObject var viewStore: ViewStore<BrandListState, BrandListAction>
    
    public init(
        store: Store<BrandListState, BrandListAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        VStack {
            if viewStore.isBrandRequestInFlight {
                ZStack {
                    Color(colorScheme == .light ? .secondarySystemBackground : .systemBackground)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView()
                }
            } else {
                List {
                    
                    if !viewStore.userBrands.isEmpty {
                        Section(
                            header: Text("My Brands")
                        ) {
                            ForEach(viewStore.userBrands) { brand in
                                Button(action: { viewStore.send(.setSelected(brand: brand)) }) {
                                    HStack {
                                        Text(brand.brand)
                                        Spacer()
                                        
                                        if brand == viewStore.selectedBrand {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.green)
                                        }
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .foregroundColor(.primary)
                                }
                            }
                        }
                        .textCase(nil)
                    }
                    
                    if !viewStore.recentBrands.isEmpty {
                        Section(
                            footer: Text("Recent Brands")
                        ) {
                            ForEach(viewStore.recentBrands) { recentBrand in
                                Button(action: { viewStore.send(.setSelected(brand: recentBrand)) }) {
                                    HStack {
                                        Text(recentBrand.brand)
                                        Spacer()
                                        
                                        if recentBrand == viewStore.selectedBrand {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.green)
                                        }
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    
                    ForEach(viewStore.filteredBrands) { brand in
                        Button(action: { viewStore.send(.setSelected(brand: brand)) }) {
                            HStack {
                                Text(brand.brand)
                                Spacer()
                                
                                if brand == viewStore.selectedBrand {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    
                }
                .searchable(
                    text: viewStore.binding(\.$filterQuery),
                    placement: .automatic,
                    prompt: Text("Filter")
                )
            }
        }
        .sheet(
            isPresented: viewStore.binding(\.$isAddBrandNavigationActive).removeDuplicates()
        ) {
            NavigationView {
                AddBrandView(
                    store: store.scope(
                        state: \.addBrandState,
                        action: BrandListAction.addBrandAction
                    )
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { viewStore.send(.addBrandClosedTapped) }) {
                            Image(systemName: "xmark")
                                .font(.body.bold())
                        }
                    }
                }
            }
            .accentColor(viewStore.userSettings.accentColor.color)
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .onAppear {
            viewStore.send(.viewLoaded)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewStore.send(.addBrandButtonTapped) }) {
                    Image(systemName: "plus")
                }
                .foregroundColor(viewStore.userSettings.accentColor.color)
            }
        }
    }
}

struct BrandListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BrandListView(
                store: Store(
                    initialState: BrandListState(
                        recentBrands: [
                            .shimano
                        ],
                        userBrands: [
                            .init(id: 00123, brand: "Owenhouse", isComponentManufacturerOnly: false)
                        ],
                        userSettings: .init())
                    ,
                    reducer: brandListReducer,
                    environment: BrandListEnvironment())
            )
            .navigationTitle("Brands")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
