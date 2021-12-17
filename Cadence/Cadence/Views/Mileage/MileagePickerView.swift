import SwiftUI
import ComposableArchitecture

typealias MileagePickerReducer = Reducer<MileagePickerState, MileagePickerAction, MileagePickerEnvironment>

// TODO: - Can we localize?

enum MileageOption: Int, CaseIterable, Codable {
    case twoHundredFifty = 250
    case fiveHundred = 500
    case oneThousand = 1_000
    case custom
    
    var title: String {
        switch self {
        case .twoHundredFifty:
            return "250"
        case .fiveHundred:
            return "500"
        case .oneThousand:
            return "1,000"
        case .custom:
            return "Custom"
        }
    }
}

struct MileagePickerState: Equatable {
    @BindableState var selectedOption: MileageOption = .fiveHundred
    @BindableState var customText = ""
    var isShowingCustomTextField = false
}

enum MileagePickerAction: BindableAction, Equatable {
    case binding(BindingAction<MileagePickerState>)
    case didTapSave
}

struct MileagePickerEnvironment {}

let mileagePickerReducer = MileagePickerReducer
{ state, action, environment in
    switch action {
    case .binding(\.$selectedOption):
        if state.selectedOption == .custom {
            state.isShowingCustomTextField = true
        } else {
            state.isShowingCustomTextField = false
            state.customText = ""
        }
        
        return .none
        
    default:
        return .none
    }
}
.binding()
.onChange(of: \.customText) { val, state, action, environment in
    if val == "0" {
        state.customText = ""
    }
    return .none
}

struct MileagePickerView: View {
    let store: Store<MileagePickerState, MileagePickerAction>
    @ObservedObject var viewStore: ViewStore<MileagePickerState, MileagePickerAction>
    
    init(
        store: Store<MileagePickerState, MileagePickerAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
        List {
            Section(
                footer: Text("As you ride your bike, Cadence will notify you as you get close to the alert you set. You can change this later if you would like.")
            ) {
                ForEach(MileageOption.allCases, id: \.self) { option in
                    HStack {
                        HStack {
                            Button(action: { viewStore.send(.set(\.$selectedOption, option)) }) {
                                HStack {
                                    Text("\(option.title)")
                                    Spacer()
                                    
                                    Image(systemName: option == viewStore.selectedOption ? "checkmark.circle.fill" : "circle")
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                if viewStore.isShowingCustomTextField {
                    TextField("Custom", text: viewStore.binding(\.$customText), prompt: Text("475"))
                        .keyboardType(.numberPad)
                }
            }
        }
        .navigationTitle("Mileage Alert")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: { viewStore.send(.didTapSave) })
            }
        }
    }
}

struct MileagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MileagePickerView(
                store: Store(
                    initialState: MileagePickerState(),
                    reducer: mileagePickerReducer,
                    environment: MileagePickerEnvironment()
                )
            )
        }
    }
}
