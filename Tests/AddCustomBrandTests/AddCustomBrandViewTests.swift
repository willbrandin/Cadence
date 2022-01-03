import Combine
import ComposableArchitecture
import XCTest
import SnapshotTesting
import SwiftUI
import AddCustomBrandFeature

class AddCustomBrandViewTests: XCTestCase {
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
    
    func testAddCustomBrandText() {
        let environment = AddBrandEnvironment.failing
        
        let store = Store(
            initialState: AddBrandState(
                brandName: "Owenhouse",
                isComponentOnly: true,
                alert: nil
            ),
            reducer: addBrandReducer,
            environment: environment
        )
        
        var snapshotView: some View {
            NavigationView {
                AddBrandView(store: store)
            }
        }
        
        assertSnapshot(
            matching: snapshotView,
            as: .image(layout: .device(config: .iPhoneXsMax))
        )
    }
}
