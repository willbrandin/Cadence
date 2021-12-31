import Combine
import ComposableArchitecture
import XCTest

@testable import UserSettingsFeature

class UserSettingsFeatureTests: XCTestCase {
    func testColorScheme() {
        let scheduler = DispatchQueue.test
        var environment: SettingsEnvironment = .failing
        
        environment.uiUserInterfaceStyleClient.setUserInterfaceStyle = { _ in .none }
        environment.mainQueue = scheduler.eraseToAnyScheduler()
        environment.fileClient = .noop
        
        let store = TestStore(
            initialState: SettingsState(),
            reducer: userSettingsReducer,
            environment: environment
        )
        
        store.send(.set(\.$isColorSchemeNavigationActive, true)) {
            $0.colorScheme = .system
            $0.isColorSchemeNavigationActive = true
        }
        
        store.send(.set(\.$colorScheme, .light)) {
            $0.colorScheme = .light
        }
        
        store.send(.set(\.$isColorSchemeNavigationActive, false)) {
            $0.isColorSchemeNavigationActive = false
        }
        
        scheduler.run()
    }
    
    func testDistanceUnit() {
        let scheduler = DispatchQueue.test
        var environment: SettingsEnvironment = .failing

        environment.mainQueue = scheduler.eraseToAnyScheduler()
        environment.fileClient = .noop

        let store = TestStore(
            initialState: SettingsState(),
            reducer: userSettingsReducer,
            environment: environment
        )
        
        store.send(.set(\.$isUnitPickerNavigationActive, true)) {
            $0.distanceUnit = .miles
            $0.isUnitPickerNavigationActive = true
        }
        
        store.send(.set(\.$distanceUnit, .kilometers)) {
            $0.distanceUnit = .kilometers
        }
        
        store.send(.set(\.$isUnitPickerNavigationActive, false)) {
            $0.isUnitPickerNavigationActive = false
        }
        
        scheduler.run()
    }
}
