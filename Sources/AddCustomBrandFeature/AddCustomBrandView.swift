import BrandClient
import ComposableArchitecture
import Models
import SwiftUI
import World

public typealias AddBrandReducer = Reducer<AddBrandState, AddBrandAction, AddBrandEnvironment>

public struct AddBrandState: Equatable {
    public init(
        brandName: String = "",
        brands: [Brand] = [],
        isComponentOnly: Bool = false,
        alert: AlertState<AddBrandAction>? = nil
    ) {
        self.brandName = brandName
        self.brands = brands
        self.isComponentOnly = isComponentOnly
        self.alert = alert
    }
    
    public var brands: [Brand]
    @BindableState public var brandName: String
    @BindableState public var isComponentOnly: Bool
    @BindableState public var alert: AlertState<AddBrandAction>?
}

public enum AddBrandAction: Equatable, BindableAction {
    case binding(BindingAction<AddBrandState>)
    case saveButtonTapped
    case saveBrandResponse(Result<Brand, BrandClient.Failure>)
    case didAddBrand(Brand)
    case didTapClose
    case alertOkayTapped
    case alertDismissed
    case viewLoaded
    case delete(atOffset: IndexSet)
    case deleteAlertTapped(forOffset: IndexSet)
    case brandsRequestResult(Result<[Brand], BrandClient.Failure>)
}

public struct AddBrandEnvironment {
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

public let addBrandReducer = AddBrandReducer
{ state, action, environment in
    switch action {
    case .alertOkayTapped, .alertDismissed:
        state.alert = nil
        return .none
        
    case .saveButtonTapped:
        if state.brandName.isEmpty {
            state.alert = AlertState(
                title: .init("Brand name cannot be empty"),
                message: nil,
                dismissButton: .default(.init("Okay"), action: .send(.alertOkayTapped))
            )
            return .none
        }
        
        let id = Current.randomNumber()
        let brand = Brand(id: id, brand: state.brandName, isComponentManufacturerOnly: state.isComponentOnly)
        
        return environment.brandClient.createUserBrand(brand)
            .receive(on: environment.mainQueue)
            .catchToEffect(AddBrandAction.saveBrandResponse)
        
    case let .saveBrandResponse(.success(brand)):
        return Effect(value: .didAddBrand(brand))
            .eraseToEffect()
        
    case let .saveBrandResponse(.failure(error)):
        state.alert = AlertState(
            title: .init("Sorry, could not save brand."),
            message: .init("Please try again."),
            dismissButton: .default(.init("Okay"), action: .send(.alertOkayTapped))
        )
        
        return .none
        
    case let .deleteAlertTapped(forOffset: indexSet):
        indexSet.forEach { index in
            state.brands.remove(at: index)
        }
        
        return .none
        
    case let .delete(atOffset: indexSet):
        state.alert = AlertState(
            title: .init("Are you sure you want to delete this brand?"),
            message: .init("Existing components will not be changed."),
            buttons: [
                .destructive(.init("Yes, Delete"), action: .send(.deleteAlertTapped(forOffset: indexSet)))
            ]
        )
        
        return .none
        
    case let .brandsRequestResult(.success(brands)):
        state.brands = brands
        return .none
        
    case .viewLoaded:
        return environment.brandClient.requestUserBrands()
            .receive(on: environment.mainQueue)
            .catchToEffect(AddBrandAction.brandsRequestResult)
        
    default:
        return .none
    }
}
.binding()

public struct AddBrandView: View {
    @Environment(\.colorScheme) var colorScheme

    let store: Store<AddBrandState, AddBrandAction>
    @ObservedObject var viewStore: ViewStore<AddBrandState, AddBrandAction>
    
    public init(
        store: Store<AddBrandState, AddBrandAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        Form {
            Section(
                footer: Text(
                    "Create your own brand. If iCloud is enabled, the Brand will appear on all your devices."
                )
            ) {
                TextField("Brand Name", text: viewStore.binding(\.$brandName), prompt: Text("Brand"))
                Toggle("Component Manufacturer Only", isOn: viewStore.binding(\.$isComponentOnly))
            }
            
            Section(
                header: Text("My Brands")
            ) {
                ForEach(viewStore.brands) { brand in
                    HStack {
                        Text(brand.brand)
                            .font(.subheadline.bold())
                            .foregroundColor(.secondary)
                    }
                }
//                .onDelete { offset in
//                    viewStore.send(.delete(atOffset: offset))
//                }
            }
        }
        .navigationTitle("Add Brand")
        .onAppear {
            viewStore.send(.viewLoaded)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { viewStore.send(.saveButtonTapped) }) {
                    Text("Save")
                }
                .alert(
                    self.store.scope(state: \.alert),
                    dismiss: .alertDismissed
                )
            }
        }
    }
}

struct AddBrandView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddBrandView(
                store: Store(
                    initialState: AddBrandState(brands: [.shimano]),
                    reducer: addBrandReducer,
                    environment: AddBrandEnvironment(brandClient: .mocked, mainQueue: .main)
                )
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
public extension AddBrandEnvironment {
    static var failing: Self {
        Self(
            brandClient: .alwaysFailing,
            mainQueue: .failing
        )
    }
}
#endif
