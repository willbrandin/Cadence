import SwiftUI
import ComposableArchitecture
import Models
import MileageScaleFeature

public typealias ComponentSelectorReducer = Reducer<ComponentSelectorState, ComponentSelectorAction, ComponentSelectorEnvironment>

public struct ComponentSelectorState: Equatable {
    public init(
        components: [Component] = [
            .shimanoSLXBrakes,
            .shimanoXLTBrakeRotor,
            .racefaceCogsette,
            .wtbFrontWheelSet,
            .yeti165Frame,
            .racefaceCarbon69Handlebars
        ],
        selectedComponents: [UUID : Component] = [Component.racefaceCarbon69Handlebars.id: .racefaceCarbon69Handlebars],
        filteredComponents: [Component] = [
            .shimanoSLXBrakes,
            .shimanoXLTBrakeRotor,
            .racefaceCogsette,
            .wtbFrontWheelSet,
            .yeti165Frame,
            .racefaceCarbon69Handlebars
        ],
        filterQuery: String = "",
        distanceUnit: DistanceUnit = .miles
    ) {
        self.components = components
        self.selectedComponents = selectedComponents
        self.filteredComponents = filteredComponents
        self.filterQuery = filterQuery
        self.distanceUnit = distanceUnit
    }
    
    public var components: [Component]
    public var selectedComponents: [UUID: Component]
    public var filteredComponents: [Component]
    public var distanceUnit: DistanceUnit
    @BindableState public var filterQuery: String
}

public enum ComponentSelectorAction: Equatable, BindableAction {
    case binding(BindingAction<ComponentSelectorState>)
    case didSelect(component: Component)
}

public struct ComponentSelectorEnvironment {
    public init() {}
}

public let componentSelectorReducer = ComponentSelectorReducer
{ state, action, environment in
    switch action {
    case let .didSelect(component):
        if state.selectedComponents[component.id] != nil {
            state.selectedComponents.removeValue(forKey: component.id)
        } else {
            state.selectedComponents[component.id] = component
        }
        
        return .none
    default:
        return .none
    }
}
.binding()

struct ComponentSelectorRow: View {
    let component: Component
    let isSelected: Bool
    let distanceUnit: DistanceUnit
    
    var body: some View {
        VStack(spacing: 8) {
            VStack {
                HStack {
                    Text(component.cellTitle)
                        .bold()
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    HStack(spacing: 2) {
                        Text(component.brand.brand)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        if let model = component.model {
                            Text(model)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    
                    Spacer()
                }
                
            }
            HStack {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(component.mileage.miles)")
                        .font(.title2)
                        .fontWeight(.black)
                    Text(distanceUnit.title)
                        .font(.callout)
                        .bold()
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack {
                    MileageScaleView(mileage: component.mileage)
                }
            }
        }
        .foregroundColor(.primary)
        .padding(.vertical, 4)
    }
}

public struct ComponentSelectorView: View {
    let store: Store<ComponentSelectorState, ComponentSelectorAction>
    @ObservedObject var viewStore: ViewStore<ComponentSelectorState, ComponentSelectorAction>
    
    public init(
        store: Store<ComponentSelectorState, ComponentSelectorAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        List {
            Section(
                header: Text("Some maintenance affects multiple components. Select all that may be affected.")
            ) {
                ForEach(viewStore.components) { component in
                    Button(action: { viewStore.send(.didSelect(component: component)) }) {
                        ComponentSelectorRow(
                            component: component,
                            isSelected: viewStore.selectedComponents[component.id] != nil,
                            distanceUnit: viewStore.distanceUnit
                        )
                    }
                }
            }
            .textCase(nil)
        }
        .navigationTitle("Component Service")
    }
}

struct ComponentSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ComponentSelectorView(
                    store: Store(
                        initialState: ComponentSelectorState(),
                        reducer: componentSelectorReducer,
                        environment: ComponentSelectorEnvironment())
                )
            }
            NavigationView {
                Text("")
                ComponentSelectorView(
                    store: Store(
                        initialState: ComponentSelectorState(),
                        reducer: componentSelectorReducer,
                        environment: ComponentSelectorEnvironment())
                )
            }
            .previewDevice("iPad Air (4th generation)")
            .previewInterfaceOrientation(.landscapeLeft)
        }
    }
}

