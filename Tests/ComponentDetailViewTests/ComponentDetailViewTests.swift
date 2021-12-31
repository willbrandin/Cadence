import Combine
import ComposableArchitecture
import XCTest
import SnapshotTesting
import Models
import SwiftUI

@testable import ComponentDetailFeature

class ComponentDetailViewTests: XCTestCase {
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
    
    func testComponentView() {
        var component: Component = .shimanoSLXRearDerailleur
        component.addedToBikeDate = Date.initFromComponents(year: 2020, month: 9, day: 15, hour: 8, minute: 30)!
        component.mileage = .okay

        let store = Store(
            initialState: ComponentDetailState(component: component),
            reducer: componentDetailReducer,
            environment: .mocked
        )
        
        var snapshotView: some View {
            NavigationView {
                ComponentDetailView(store: store)
            }
        }
        
        assertSnapshot(
            matching: snapshotView,
            as: .image(layout: .device(config: .iPhoneXsMax))
        )
    }
}
