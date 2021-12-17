import Combine
import ComposableArchitecture
import XCTest
import SnapshotTesting
import SwiftUI

@testable import Cadence

class AppSettingsViewTests: XCTestCase {
    static override func setUp() {
        super.setUp()
        
        SnapshotTesting.diffTool = "ksdiff"
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
//        isRecording = true
    }
    
    override func tearDown() {
        isRecording = false
        
        super.tearDown()
    }
    
    func testSettings() {
        var environment = SettingsEnvironment.failing
        
        environment.applicationClient.supportsAlternateIcons = { true }
        environment.applicationClient.alternateIconName = { nil }
        
        let store = Store(
            initialState: SettingsState(),
            reducer: userSettingsReducer,
            environment: environment
        )
        
        var snapshotView: some View {
            NavigationView {
                SettingsView(store: store)
            }
        }
        
        assertSnapshot(
            for: snapshotView,
            colorScheme: .light
        )
    }
}
