import Combine
import ComposableArchitecture
import XCTest

@testable import Cadence

class SignUpFormFeatureTests: XCTestCase {
    func testSignUp_FocusState() {
        let store = TestStore(
            initialState: SignUpState(),
            reducer: signUpReducer,
            environment: SignUpEnvironment()
        )
        
        store.send(.binding(.set(\.$focusedField, .name))) {
            $0.focusedField = .name
        }
        
        store.send(.binding(.set(\.$focusedField, nil))) {
            $0.focusedField = nil
        }
        
        store.send(.binding(.set(\.$focusedField, .email))) {
            $0.focusedField = .email
        }
        
        store.send(.binding(.set(\.$focusedField, .password))) {
            $0.focusedField = .password
        }
        
        store.send(.binding(.set(\.$focusedField, nil))) {
            $0.focusedField = nil
        }
        
        store.send(.signUpButtonTapped) {
            $0.focusedField = .name
        }
        
        store.send(.binding(.set(\.$name, "John"))) {
            $0.name = "John"
        }
        
        store.send(.signUpButtonTapped) {
            $0.focusedField = .email
        }
        
        store.send(.binding(.set(\.$email, "john@email.com"))) {
            $0.email = "john@email.com"
        }
        
        store.send(.signUpButtonTapped) {
            $0.focusedField = .password
        }
        
        store.send(.binding(.set(\.$password, "123456"))) {
            $0.password = "123456"
        }
        
        store.send(.signUpButtonTapped) {
            $0.focusedField = nil
        }
    }
}
