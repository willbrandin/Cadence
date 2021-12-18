import SwiftUI
import ComposableArchitecture
import Models
import BrandListFeature
import BrandClient
import ComponentClient
import World

typealias CreateComponentReducer = Reducer<CreateComponentState, CreateComponentAction, CreateComponentEnvironment>

struct CreateComponentState: Equatable {
    @BindableState var model: String = ""
    @BindableState var description: String = ""
    @BindableState var date: Date = Current.date()
    @BindableState var isCustomDate = false
    @BindableState var isMileageSettingNavigationActive = false

    var bikeId: UUID
    var brand: Brand = .sram
    var componentGroup: ComponentGroup = .drivetrain
    var componentType: ComponentType = .cassette
    var recommendedMiles = 500
    var isCreateComponentRequestInFlight = false
    var mileagePickerState: MileagePickerState?
    var brandListState: BrandListState?
    var isBrandNavigationActive = false
    var distanceUnit: DistanceUnit = .miles

    var mileageText: String {
        return "\(recommendedMiles) \(distanceUnit.title)"
    }

    var dateText: String {
        if Date.isToday(date) {
            return "Today"
        } else {
            let formatter = Current.dateFormatter(dateStyle: .medium, timeStyle: .none)
            return formatter.string(from: date)
        }
    }
}

enum CreateComponentAction: Equatable, BindableAction {
    case binding(BindingAction<CreateComponentState>)
    case didTapMileageAlert
    case didTapSave
    case componentSavedResponse(Result<Component, ComponentClient.Failure>)
    case componentSaved(Component)
    case mileagePicker(MileagePickerAction)
    case setBrandNavigation(isActive: Bool)
    case brandList(BrandListAction)
}

struct CreateComponentEnvironment {
    var componentClient: ComponentClient = .noop
    var brandClient: BrandClient = .mocked
    var mainQueue: AnySchedulerOf<DispatchQueue> = .main
    var date: () -> Date = Current.date
    var uuid: () -> UUID = Current.uuid
}

extension CreateComponentEnvironment {
    static let failing = Self(
        componentClient: .failing,
        mainQueue: .failing,
        date: { return .distantPast },
        uuid: { .init() }
    )
}

private let reducer = CreateComponentReducer
{ state, action, environment in
    switch action {
    case let .componentSavedResponse(.success(component)):
        state.isCreateComponentRequestInFlight = false
        return Effect(value: CreateComponentAction.componentSaved(component))
            .eraseToEffect()
        
    case let .componentSavedResponse(.failure(error)):
        state.isCreateComponentRequestInFlight = false
        return .none
        
    case .didTapSave:
        state.isCreateComponentRequestInFlight = true
        
        let component = Component(
            id: environment.uuid(),
            model: state.model,
            description: state.description,
            componentTypeId: state.componentType,
            componentGroupId: state.componentGroup,
            addedToBikeDate: state.date,
            mileage: Mileage(id: environment.uuid(), miles: 0, recommendedMiles: state.recommendedMiles),
            maintenances: [],
            brand: state.brand
        )

        return environment.componentClient.create(state.bikeId.uuidString, component)
            .receive(on: environment.mainQueue)
            .catchToEffect(CreateComponentAction.componentSavedResponse)

    case .binding(.set(\.$isCustomDate, false)):
        state.date = environment.date()
        return .none
        
    case .binding(\.$date):
        // If we are locking to today's date, do not allow the state to change.
        if !state.isCustomDate {
            state.date = environment.date()
        }
        
        return .none
        
    case .mileagePicker(.didTapSave):
        guard let pickerState = state.mileagePickerState
        else { return .none }
        
        var miles = MileageOption.fiveHundred.rawValue
        
        if pickerState.selectedOption == .custom {
            if let customMiles = Int(pickerState.customText) {
                miles = customMiles
            }
        } else {
            miles = pickerState.selectedOption.rawValue
        }
        
        state.recommendedMiles = miles
        state.isMileageSettingNavigationActive = false
        return .none
        
    case .setBrandNavigation(false):
        state.brandListState = nil
        state.isBrandNavigationActive = false
        return .none
        
    case .setBrandNavigation(isActive: true):
        state.brandListState = BrandListState(brandContext: .components, selectedBrand: state.brand)
        state.isBrandNavigationActive = true
        return .none
        
    case let .brandList(.setSelected(brand: brand)):
        state.brand = brand
        return .none
        
    case .binding(\.$isMileageSettingNavigationActive):
        if state.isMileageSettingNavigationActive {
            if let option = MileageOption(rawValue: state.recommendedMiles) {
                state.mileagePickerState = MileagePickerState(selectedOption: option)
            } else {
                state.mileagePickerState = MileagePickerState(selectedOption: .custom, customText: "\(state.recommendedMiles)", isShowingCustomTextField: true)
            }
        }
        
    default:
        return .none
    }
    
    return .none
}
.binding()

let addComponentReducer: CreateComponentReducer = .combine(
    mileagePickerReducer
        .optional()
        .pullback(
            state: \.mileagePickerState,
            action: /CreateComponentAction.mileagePicker,
            environment: { _ in MileagePickerEnvironment() }
        ),
    brandListReducer
        .optional()
        .pullback(
            state: \.brandListState,
            action: /CreateComponentAction.brandList,
            environment: {
                BrandListEnvironment(
                    brandClient: $0.brandClient,
                    mainQueue: $0.mainQueue
                )
            }
        ),
    reducer
)

struct CreateComponentView: View {
    let store: Store<CreateComponentState, CreateComponentAction>
    @ObservedObject var viewStore: ViewStore<CreateComponentState, CreateComponentAction>
    
    init(
        store: Store<CreateComponentState, CreateComponentAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
        List {
            Section {
                
                NavigationLink(
                    isActive: viewStore
                        .binding(
                            get: \.isBrandNavigationActive,
                            send: CreateComponentAction.setBrandNavigation
                        )
                        .removeDuplicates()
                    )
                {
                    VStack {
                        IfLetStore(
                            self.store.scope(
                                state: \.brandListState,
                                action: CreateComponentAction.brandList
                            ),
                            then: BrandListView.init
                        )
                        .navigationTitle("Component Brand")
                    }
                } label: {
                    HStack {
                        Text("Brand Name")
                        Spacer()
                        Text(viewStore.brand.brand)
                            .foregroundColor(.secondary)
                    }
                }
            
                TextField(
                    "Model",
                    text: viewStore.binding(\.$model),
                    prompt: Text("GX-Eagle")
                )
                
                TextField(
                    "Description",
                    text: viewStore.binding(\.$description),
                    prompt: Text("Rear Derailleur")
                )
            }
            
            Section {
                HStack {
                    Text("Category")
                    Spacer()
                    Text(viewStore.componentGroup.title)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Type")
                    Spacer()
                    Text(viewStore.componentType.title)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(
                footer: Text("As you ride your bike, Cadence will notify you as you get close to the alert you set.")
            ) {
                NavigationLink(
                    destination:
                        IfLetStore(store.scope(
                            state: \.mileagePickerState,
                            action: CreateComponentAction.mileagePicker
                        ), then: MileagePickerView.init(store:)),
                    isActive: viewStore.binding(\.$isMileageSettingNavigationActive)
                ) {
                    HStack {
                        Text("Mileage Alert")
                        Spacer()
                        Text(viewStore.mileageText)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section {
                Toggle(isOn: viewStore.binding(\.$isCustomDate)) {
                    VStack(alignment: .leading) {
                        Text("Date added:")
                        Text(viewStore.dateText)
                            .font(.caption)
                    }
                }
                
                if viewStore.isCustomDate {
                    DatePicker(
                        "Date added to bike",
                        selection: viewStore.binding(\.$date),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                }
                
            }
        }
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
                Button("Save", action: { viewStore.send(.didTapSave) })
                    .foregroundColor(.accentColor)
            }
        }
    }
}

struct AddComponentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateComponentView(
                store: Store(
                    initialState: CreateComponentState(bikeId: UUID()),
                    reducer: addComponentReducer,
                    environment: CreateComponentEnvironment()
                )
            )
            .navigationTitle("Add Component")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
