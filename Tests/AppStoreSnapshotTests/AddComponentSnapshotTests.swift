import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest
import Models
import CreateComponentFeature
import HomeFeature
import SnapshotTestSupport
import BikeComponentListFeature
import ComponentDetailFeature

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
    
    func testAccountHome_Light() {
        assertAppStoreSnapshots(
            for: homeBikesView,
               description: {
                   Text("Track your entire garage.")
                       .foregroundColor(.white)
               },
               backgroundColor: .indigo,
               colorScheme: .light
        )
    }
    
    func testAccountHome_Dark() {
        assertAppStoreSnapshots(
            for: homeBikesView,
               description: {
                   Text("Track your entire garage.")
                       .foregroundColor(.black)
               },
               backgroundColor: .indigo,
               colorScheme: .dark
        )
    }
    
    func testBikeComponents_Light() {
        assertAppStoreSnapshots(
            for: bikeComponentView,
               description: {
                   Text("Add components to your bike")
                       .foregroundColor(.white)
               },
               backgroundColor: .cyan,
               colorScheme: .light
        )
    }
    
    func testBikeComponents_Dark() {
        assertAppStoreSnapshots(
            for: bikeComponentView,
               description: {
                   Text("Add components to your bike")
                       .foregroundColor(.black)
               },
               backgroundColor: .cyan,
               colorScheme: .dark
        )
    }
    
    func testComponentDetail_Light() {
        assertAppStoreSnapshots(
            for: componentDetailView,
               description: {
                   Text("Add components to your bike")
                       .foregroundColor(.white)
               },
               backgroundColor: .teal,
               colorScheme: .light
        )
    }
    
    func testComponentDetail_Dark() {
        assertAppStoreSnapshots(
            for: componentDetailView,
               description: {
                   Text("Add components to your bike")
                       .foregroundColor(.black)
               },
               backgroundColor: .teal,
               colorScheme: .dark
        )
    }
}

private var componentDetailView: AnyView {
    var component = Component.shimanoSLXRearDerailleur
    
    let date = Date.initFromComponents(year: 2021, month: 12, day: 10, hour: 8, minute: 0)!

    component.mileage = .upper
    component.maintenances = [.init(id: .init(), description: "Routine Maintenance", serviceDate: date)]
    
    
    let view = NavigationView {
        ComponentDetailView(
            store: Store(
                initialState: ComponentDetailState(
                    component: component,
                    bikeComponents: [],
                    isShowingOptions: false,
                    isAddComponentServiceNavigationActive: false,
                    addComponentServiceState: nil,
                    userSettings: .init()),
                reducer: componentDetailReducer,
                environment: ComponentDetailEnvironment(
                    componentClient: .noop,
                    maintenanceClient: .noop,
                    mainQueue: .main,
                    date: { .distantFuture },
                    uuid: { .init() }
                )
            )
        )
    }
    
    return AnyView(view)
}

private var bikeComponentView: AnyView {
    
    let view = NavigationView {
        BikeComponentListView(
            store: Store(
                initialState: BikeComponentState(
                    bike: .yetiMountain,
                    isShowing: false,
                    selection: nil,
                    isBikeOptionSheetActive: false,
                    isAddComponentFlowNavigationActive: false,
                    addComponentFlowState: nil,
                    editBikeState: nil,
                    isEditBikeFlowNavigationActive: false,
                    userSettings: .init()
                ),
                reducer: bikeComponentReducer,
                environment: BikeComponentEnvironment()
            )
        )
    }
    
    return AnyView(view)
}

private var addComponentAppStoreView: AnyView {
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
                    componentType: .brake,
                    userSettings: .init()
                ),
                reducer: addComponentReducer,
                environment: CreateComponentEnvironment(date: { date }))
        )
            .navigationTitle("Add Component")
    }
    
    return AnyView(view)
}

private var homeBikesView: AnyView {
    let view = NavigationView {
        HomeView(
            store: Store(
                initialState: HomeState(
                    bikes: [.yetiMountain, .canyonRoad],
                    selectedBike: nil,
                    isAccountBikesRequestInFlight: false,
                    isAddBikeFlowActive: false,
                    addBikeFlowState: nil,
                    settingsState: .init(),
                    addRideState: nil,
                    isSettingsSheetActive: false,
                    isAddRideSheetActive: false
                ),
                reducer: homeReducer,
                environment: .mocked
            )
        )
    }
    
    return AnyView(view)
}
