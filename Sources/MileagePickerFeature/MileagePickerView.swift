import SwiftUI
import ComposableArchitecture
import ComposableHelpers
import Models

public typealias MileagePickerReducer = Reducer<MileagePickerState, MileagePickerAction, MileagePickerEnvironment>

public struct MileagePickerState: Equatable {
    public init(
        selectedOption: MileageOption = .fiveHundred,
        customText: String = "",
        isShowingCustomTextField: Bool = false
    ) {
        self.selectedOption = selectedOption
        self.customText = customText
        self.isShowingCustomTextField = isShowingCustomTextField
    }
    
    @BindableState public var selectedOption: MileageOption = .fiveHundred
    @BindableState public var customText = ""
    public var isShowingCustomTextField = false
}

public enum MileagePickerAction: BindableAction, Equatable {
    case binding(BindingAction<MileagePickerState>)
    case didTapSave
}

public struct MileagePickerEnvironment {
    public init() {}
}

public let mileagePickerReducer = MileagePickerReducer
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

public struct MileagePickerView: View {
    let store: Store<MileagePickerState, MileagePickerAction>
    @ObservedObject var viewStore: ViewStore<MileagePickerState, MileagePickerAction>
    
    public init(
        store: Store<MileagePickerState, MileagePickerAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
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
