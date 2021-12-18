import SwiftUI
import ComposableArchitecture
import Style

typealias SignUpReducer = Reducer<SignUpState, SignUpAction, SignUpEnvironment>

struct SignUpState: Equatable {
    @BindableState var focusedField: Field? = nil
    @BindableState var name = ""
    @BindableState var email = ""
    @BindableState var password = ""
    
    enum Field: String, Hashable, Codable {
        case name, email, password
    }
}

enum SignUpAction: BindableAction {
    case binding(BindingAction<SignUpState>)
    case signUpButtonTapped
    case loginWithAppleTapped
}

struct SignUpEnvironment {}

let signUpReducer = SignUpReducer
{ state, action, environment in
    switch action {
    case .signUpButtonTapped:
        if state.name.isEmpty {
            state.focusedField = .name
        } else if state.email.isEmpty {
            state.focusedField = .email
        } else if state.password.isEmpty {
            state.focusedField = .password
        } else {
            state.focusedField = nil
        }
        
        return .none
    
    default:
        return .none
    }
}
.binding()

struct SignUpView: View {
    let store: Store<SignUpState, SignUpAction>
    @ObservedObject var viewStore: ViewStore<SignUpState, SignUpAction>
    
    @FocusState var focusedField: SignUpState.Field?
    
    init(
        store: Store<SignUpState, SignUpAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    CDTextField(
                        id: SignUpState.Field.name,
                        placeholder: "Name",
                        configuration: CDTextFieldConfiguration(
                            disableAutocorrection: false,
                            autoCapitalization: .words
                        ),
                        text: viewStore.binding(\.$name),
                        fieldActiveId: _focusedField
                    )
                    .shadow(radius: 4)
                    
                    CDTextField(
                        id: SignUpState.Field.email,
                        placeholder: "Email",
                        configuration: CDTextFieldConfiguration(
                            disableAutocorrection: false,
                            autoCapitalization: .none
                        ),
                        text: viewStore.binding(\.$email),
                        fieldActiveId: _focusedField
                    )
                    .shadow(radius: 4)
                    
                    CDTextField(
                        id: SignUpState.Field.password,
                        placeholder: "Password",
                        configuration: CDTextFieldConfiguration(
                            isSecureField: true,
                            disableAutocorrection: false,
                            autoCapitalization: .none
                        ),
                        text: viewStore.binding(\.$password),
                        fieldActiveId: _focusedField
                    )
                    .shadow(radius: 4)
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .onTapGesture {
                viewStore.send(.binding(.set(\.$focusedField, nil)))
            }
            
            VStack {
                Spacer()
                
                VStack(spacing: 4) {
                    Text("By signing up you agree to our")
                        .foregroundColor(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Button("Terms of Service", action: { })
                            .font(.caption.bold())

                        Text("and")
                            .foregroundColor(.secondary)

                        Button("Privacy Policy", action: { })
                            .font(.caption.bold())
                    }
                }
                .font(.caption)
                .padding(.bottom)
                Button("Sign Up", action: { viewStore.send(.signUpButtonTapped) })
                    .buttonStyle(PrimaryButtonStyle())
            }
        }
        .navigationTitle("Sign Up")
        .synchronize(
            viewStore.binding(\.$focusedField),
            self.$focusedField
        )
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUpView(
                store: Store(
                    initialState: SignUpState(),
                    reducer: signUpReducer,
                    environment: SignUpEnvironment()
                )
            )
        }
    }
}
