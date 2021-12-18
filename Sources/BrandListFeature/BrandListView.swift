import Foundation
import SwiftUI
import ComposableArchitecture
import BrandClient
import Models

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
        filteredBrands: [Brand] = [],
        isBrandRequestInFlight: Bool = false,
        selectedBrand: Brand? = nil,
        isAddAccountBrandNavigation: Bool = false
    ) {
        self.brandContext = brandContext
        self.brands = brands
        self.filteredBrands = filteredBrands
        self.isBrandRequestInFlight = isBrandRequestInFlight
        self.selectedBrand = selectedBrand
        self.isAddAccountBrandNavigation = isAddAccountBrandNavigation
    }
    
    public var brandContext: BrandListContext = .both
    public var brands: [Brand] = []
    public var filteredBrands: [Brand] = []
    @BindableState public var filterQuery: String = ""
    public var isBrandRequestInFlight = false
    public var selectedBrand: Brand?
    public var isAddAccountBrandNavigation = false
}

public enum BrandListAction: Equatable, BindableAction {
    case binding(BindingAction<BrandListState>)
    case setSelected(brand: Brand)
    case setAddBrandFlow(active: Bool)
    case viewLoaded
    case brandsLoaded([Brand])
    case setAddAccountBrandNavigation(isActive: Bool)
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

public let brandListReducer = BrandListReducer
{ state, action, environment in
    switch action {
    case let .setSelected(brand):
        state.selectedBrand = brand
        return .none

    case let .setAddBrandFlow(isActive):
        return .none
        
    case .viewLoaded:
        guard state.brands.isEmpty
        else { return .none }
        
        state.isBrandRequestInFlight = true
        return environment.brandClient
            .requestBrands()
            .receive(on: environment.mainQueue)
            .map(BrandListAction.brandsLoaded)
            .eraseToEffect()
        
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
        
    case let .setAddAccountBrandNavigation(isActive):
        state.isAddAccountBrandNavigation = isActive
        return .none
        
    case .binding:
        return .none
    }
}
.binding()

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
                List(viewStore.filteredBrands) { brand in
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
                .searchable(
                    text: viewStore.binding(\.$filterQuery),
                    placement: .automatic,
                    prompt: Text("Filter")
                )
            }
        }
        .onAppear {
            viewStore.send(.viewLoaded)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "plus")
                }
                .foregroundColor(.accentColor)
            }
        }
    }
}

struct BrandListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BrandListView(
                store: Store(
                    initialState: BrandListState(),
                    reducer: brandListReducer,
                    environment: BrandListEnvironment())
            )
            .navigationTitle("Brands")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
