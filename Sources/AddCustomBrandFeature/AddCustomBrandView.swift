import BrandClient
import ComposableArchitecture
import Models
import SwiftUI
import World

public typealias AddBrandReducer = Reducer<AddBrandState, AddBrandAction, AddBrandEnvironment>

public struct AddBrandState: Equatable {
    public init(
        brandName: String = "",
        isComponentOnly: Bool = false
    ) {
        self.brandName = brandName
        self.isComponentOnly = isComponentOnly
    }
    
    @BindableState public var brandName: String
    @BindableState public var isComponentOnly: Bool
}

public enum AddBrandAction: Equatable, BindableAction {
    case binding(BindingAction<AddBrandState>)
    case saveButtonTapped
    case saveBrandResponse(Result<Brand, BrandClient.Failure>)
    case didAddBrand(Brand)
    case didTapClose
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
    case .saveButtonTapped:
        let id = Current.randomNumber()
        let brand = Brand(id: id, brand: state.brandName, isComponentManufacturerOnly: state.isComponentOnly)
        
        return environment.brandClient.createUserBrand(brand)
            .receive(on: environment.mainQueue)
            .catchToEffect(AddBrandAction.saveBrandResponse)
        
    case let .saveBrandResponse(.success(brand)):
        return Effect(value: .didAddBrand(brand))
            .eraseToEffect()
        
    case let .saveBrandResponse(.failure(error)):
        return .none
        
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
        }
        .navigationTitle("Add Brand")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { viewStore.send(.saveButtonTapped) }) {
                    Text("Save")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { viewStore.send(.didTapClose) }) {
                    Image(systemName: "xmark")
                        .font(.body.bold())
                }
            }
        }
    }
}

struct AddBrandView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddBrandView(
                store: Store(
                    initialState: AddBrandState(),
                    reducer: addBrandReducer,
                    environment: AddBrandEnvironment())
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
