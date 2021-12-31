import Combine
import ComposableArchitecture
import XCTest
import SnapshotTesting
import SwiftUI

import TypeSelectionFeature

class TypeSelectionViewTests: XCTestCase {
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
    
    func testComponentGroup() {
        let store = Store(
            initialState: ComponentGroupSelectionState(selectedComponentType: .drivetrain),
            reducer: componentGroupSelectionReducer,
            environment: ComponentGroupSelectionEnvironment()
        )
        
        var snapshotView: some View {
            NavigationView {
                ComponentGroupSelectionView(store: store)
            }
        }
        
        assertSnapshot(
            matching: snapshotView,
            as: .image(layout: .device(config: .iPhoneXsMax))
        )
    }
    
    func testComponentType() {
        let store = Store(
            initialState: ComponentTypeSelectionState(selectedComponentType: .derailleur),
            reducer: componentTypeSelectionReducer,
            environment: ComponentTypeSelectionEnvironment()
        )
        
        var snapshotView: some View {
            NavigationView {
                ComponentTypeSelectionView(store: store)
            }
        }
        
        assertSnapshot(
            matching: snapshotView,
            as: .image(layout: .device(config: .iPhoneXsMax))
        )
    }
    
    func testBikeType() {
        let store = Store(
            initialState: BikeTypeSelectionState(selectedBikeType: .mountain),
            reducer: bikeTypeSelectionReducer,
            environment: BikeTypeSelectionEnvironment()
        )
        
        var snapshotView: some View {
            NavigationView {
                BikeTypeSelectionView(store: store)
            }
        }
        
        assertSnapshot(
            matching: snapshotView,
            as: .image(layout: .device(config: .iPhoneXsMax))
        )
    }
}
