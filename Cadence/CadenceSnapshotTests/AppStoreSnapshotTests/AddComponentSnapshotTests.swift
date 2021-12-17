import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest

@testable import Cadence

struct SnapshotConfig {
    let adaptiveSize: AdaptiveSize
    let deviceState: DeviceState
    let viewImageConfig: ViewImageConfig
}

//let scrollView = ViewImageConfig(safeArea: .zero, size: .init(width: 480, height: 2000))

// All sizes needed for app store
let appStoreViewConfigs: [String: SnapshotConfig] = [
    "iPhone_5_5": .init(adaptiveSize: .medium, deviceState: .phone, viewImageConfig: .iPhone8Plus),
    "iPhone_6_5": .init(adaptiveSize: .large, deviceState: .phone, viewImageConfig: .iPhoneXsMax)
    // TODO: When iPad Support is mucho better
    //  "iPad_12_9": .init(adaptiveSize: .large, deviceState: .pad, viewImageConfig: .iPadPro12_9(.portrait)),
]

class AppStoreSnapshotTests: XCTestCase {
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
    
    func testAddComponent_Snapshot () {
        assertSnapshot(
            for: addComponentAppStoreView,
               colorScheme: .light
        )
    }
    
    func testAccountHome_Snapshot() {
        assertAppStoreSnapshots(
            for: homeBikesView,
               description: {
                   Text("Track your entire garage.")
               },
               backgroundColor: Color(uiColor: .systemIndigo),
               colorScheme: .light
        )
    }
}

var addComponentAppStoreView: AnyView {
    let date = Date.initFromComponents(year: 2021, month: 8, day: 23, hour: 8, minute: 0)!
    
    let view = NavigationView {
        CreateComponentView(
            store: Store(
                initialState: CreateComponentState(
                    model: "SLX",
                    description: "Front Break",
                    date: date,
                    bikeId: Bike.yetiMountain.id,
                    brand: .shimano,
                    componentGroup: .brakes,
                    componentType: .brake
                ),
                reducer: addComponentReducer,
                environment: CreateComponentEnvironment(date: { date }))
        )
            .navigationTitle("Add Component")
    }
    
    return AnyView(view)
}

var homeBikesView: AnyView {
    let view = NavigationView {
        HomeView(
            store: Store(
                initialState: HomeState(
                    bikes: [.yetiMountain, .canyonRoad]
                ),
                reducer: homeReducer,
                environment: .mocked
            )
        )
    }
    
    return AnyView(view)
}
