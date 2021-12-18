import SwiftUI
import ComposableArchitecture
import Models
import MileageScaleFeature

typealias ComponentSelectorReducer = Reducer<ComponentSelectorState, ComponentSelectorAction, ComponentSelectorEnvironment>

struct ComponentSelectorState: Equatable {
    var components: [Component] = [
        .shimanoSLXBrakes,
        .shimanoXLTBrakeRotor,
        .racefaceCogsette,
        .wtbFrontWheelSet,
        .yeti165Frame,
        .racefaceCarbon69Handlebars
    ]
    
    var selectedComponents: [UUID: Component] = [Component.racefaceCarbon69Handlebars.id: .racefaceCarbon69Handlebars]

    var filteredComponents: [Component] = [
        .shimanoSLXBrakes,
        .shimanoXLTBrakeRotor,
        .racefaceCogsette,
        .wtbFrontWheelSet,
        .yeti165Frame,
        .racefaceCarbon69Handlebars
    ]
    
    @BindableState var filterQuery = ""
    var distanceUnit: DistanceUnit = .miles
}

enum ComponentSelectorAction: Equatable, BindableAction {
    case binding(BindingAction<ComponentSelectorState>)
    case didSelect(component: Component)
}

struct ComponentSelectorEnvironment {}

let componentSelectorReducer = ComponentSelectorReducer
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

struct ComponentSelectorView: View {
    let store: Store<ComponentSelectorState, ComponentSelectorAction>
    @ObservedObject var viewStore: ViewStore<ComponentSelectorState, ComponentSelectorAction>
    
    init(
        store: Store<ComponentSelectorState, ComponentSelectorAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
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
        NavigationView {
            ComponentSelectorView(
                store: Store(
                    initialState: ComponentSelectorState(),
                    reducer: componentSelectorReducer,
                    environment: ComponentSelectorEnvironment())
            )
        }
    }
}

