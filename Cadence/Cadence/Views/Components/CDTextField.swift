import SwiftUI
import ComposableArchitecture
import SwiftUIHelpers

struct CDTextField<Field: Hashable>: View {
    
    var id: Field
    var placeholder: String = ""
    var configuration: CDTextFieldConfiguration = CDTextFieldConfiguration()
    
    @Binding var text: String

    var onClear: ((String) -> Void)?
    
    @FocusState var fieldActiveId: Field?
    
    private var fieldActive: Bool {
        return fieldActiveId == id
    }

    private var isFocused: Bool {
        if fieldActive {
            return true
        } else {
            return !text.isEmpty
        }
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                if configuration.isSecureField {
                    SecureField("", text: $text, prompt: nil)
                } else {
                    TextField("", text: $text, prompt: nil)
                }
            }
            .font(.body.bold())
            .padding()
            .offset(y: 8)
            .focused($fieldActiveId, equals: id)
            .disableAutocorrection(configuration.disableAutocorrection)
            .autocapitalization(configuration.autoCapitalization)
            .keyboardType(configuration.keyboardType)
            
            Text(placeholder)
                .font(.body.bold())
                .foregroundColor(Color(.lightGray))
                .scaleEffect(isFocused ? 0.75 : 1, anchor: .topLeading)
                .offset(y: isFocused ? -14 : 0)
                .padding(.leading)
                .animation(.interactiveSpring(), value: isFocused)
            
            if fieldActive {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        if let onClear = onClear {
                            onClear(text)
                        } else {
                            clearText()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(.darkGray))
                            .padding(4)
                            .background(.thickMaterial, in: Circle())
                    }
                    .padding()
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .onTapGesture {
            if !fieldActive {
                fieldActiveId = self.id
            }
        }
    }
    
    func clearText() {
        self.text = ""
    }
}

struct CDTextField_Previews: PreviewProvider {
    static var previews: some View {
        FocusDemoView(
          store: Store(
            initialState: .init(),
            reducer: focusDemoReducer.debug(),
            environment: .init()
          )
        )
    }
}

struct CDTextFieldConfiguration {
    var isSecureField = false
    var keyboardType: UIKeyboardType = .default
    var disableAutocorrection = false
    var autoCapitalization: UITextAutocapitalizationType = .sentences
}
 
// MARK: - Composable Demo

struct FocusDemoState: Equatable {
    @BindableState var focusedField: Field? = nil
    @BindableState var password: String = ""
    @BindableState var username: String = ""
    
    enum Field: String, Hashable {
        case username, password
    }
}

enum FocusDemoAction: Equatable, BindableAction {
    case binding(BindingAction<FocusDemoState>)
    case signInButtonTapped
}

struct FocusDemoEnvironment {}

let focusDemoReducer = Reducer<
    FocusDemoState,
    FocusDemoAction,
    FocusDemoEnvironment
> { state, action, _ in
    switch action {
    case .binding:
        return .none
        
    case .signInButtonTapped:
        if state.username.isEmpty {
            state.focusedField = .username
        } else if state.password.isEmpty {
            state.focusedField = .password
        } else {
            state.focusedField = nil
        }
        
        return .none
    }
}
.binding()

struct FocusDemoView: View {
    let store: Store<FocusDemoState, FocusDemoAction>
    @FocusState var focusedField: FocusDemoState.Field?
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .leading, spacing: 32) {
                VStack {
                    
                    CDTextField(
                        id: FocusDemoState.Field.username,
                        placeholder: "Email",
                        text: viewStore.binding(\.$username),
                        fieldActiveId: _focusedField
                    )
                        .shadow(radius: 4)
                        .padding()
                    
                    CDTextField(
                        id: FocusDemoState.Field.password,
                        placeholder: "Password",
                        configuration: CDTextFieldConfiguration(isSecureField: true),
                        text: viewStore.binding(\.$password),
                        fieldActiveId: _focusedField
                    )
                        .shadow(radius: 4)
                        .padding()
                    
                    Button("Sign In") {
                        viewStore.send(.signInButtonTapped)
                    }
                }
                
                Spacer()
            }
            .padding()
            .synchronize(
                viewStore.binding(\.$focusedField),
                self.$focusedField
            )
        }
        .navigationBarTitle("Focus demo")
    }
}
