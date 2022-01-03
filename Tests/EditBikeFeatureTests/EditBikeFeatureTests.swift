import Combine
import ComposableArchitecture
import Models
import XCTest
import World
import BikeClient
import EditBikeFeature

class EditBikeFeatureTests: XCTestCase {
    func testEditBike_Name() {
        let environment = EditBikeEnvironment.init(
            bikeClient: .failing,
            mainQueue: .failing
        )
        
        let store = TestStore(
            initialState: EditBikeState(
                bike: .yetiMountain,
                isSaveBikeRequestInFlight: false,
                userSettings: .init()
            ),
            reducer: editBikeReducer,
            environment: environment
        )
        
        store.send(.updateBikeName(name: "YETI")) {
            $0.bikeName = "YETI"
        }
    }
    
    func testEmptyBikeNameAlert() {
        let environment = EditBikeEnvironment.init(
            bikeClient: .failing,
            mainQueue: .failing
        )
        
        let store = TestStore(
            initialState: EditBikeState(
                bike: .yetiMountain,
                isSaveBikeRequestInFlight: false,
                userSettings: .init()
            ),
            reducer: editBikeReducer,
            environment: environment
        )
        
        store.send(.updateBikeName(name: "")) {
            $0.bikeName = ""
        }
        
        store.send(.saveBike) {
            $0.alert = AlertState(
                title: .init("Bike name cannot be empty"),
                dismissButton: .default(.init("Okay"), action: .send(.alertOkayTapped))
            )
        }
        
        store.send(.alertOkayTapped) {
            $0.alert = nil
        }
    }
    
    func testSaveBike() {
        var environment = EditBikeEnvironment.init(
            bikeClient: .failing,
            mainQueue: .failing
        )
        
        let scheduler = DispatchQueue.test
        
        environment.mainQueue = scheduler.eraseToAnyScheduler()
        
        var updatedBike = Bike.yetiMountain
        updatedBike.name = "YETI"
        
        environment.bikeClient.update = { bike in
            guard bike == updatedBike
            else { return .failing("Bikes do not match") }
            
            return Effect(value: bike)
        }
        
        let store = TestStore(
            initialState: EditBikeState(
                bike: .yetiMountain,
                isSaveBikeRequestInFlight: false,
                userSettings: .init()
            ),
            reducer: editBikeReducer,
            environment: environment
        )
        
        store.send(.updateBikeName(name: "YETI")) {
            $0.bikeName = "YETI"
        }
        
        store.send(.saveBike) {
            $0.isSaveBikeRequestInFlight = true
        }
        
        scheduler.advance()
        
        store.receive(.saveBikeResponse(.success(updatedBike))) {
            $0.isSaveBikeRequestInFlight = false
        }
        
        store.receive(.bikeSaved(updatedBike))
        
        scheduler.run()
    }
    
    func testSaveBike_Failure() {
        var environment = EditBikeEnvironment.init(
            bikeClient: .failing,
            mainQueue: .failing
        )
        
        let scheduler = DispatchQueue.test
        
        environment.mainQueue = scheduler.eraseToAnyScheduler()
        
        let failure = BikeClient.Failure()
        
        environment.bikeClient.update = { _ in
            return Effect(error: failure)
        }
        
        let store = TestStore(
            initialState: EditBikeState(
                bike: .yetiMountain,
                isSaveBikeRequestInFlight: false,
                userSettings: .init()
            ),
            reducer: editBikeReducer,
            environment: environment
        )
        
        store.send(.updateBikeName(name: "YETI")) {
            $0.bikeName = "YETI"
        }
        
        store.send(.saveBike) {
            $0.isSaveBikeRequestInFlight = true
        }
        
        scheduler.advance()
        
        store.receive(.saveBikeResponse(.failure(failure))) {
            $0.isSaveBikeRequestInFlight = false
            $0.alert = AlertState(
                title: .init("Something went wrong"),
                message: .init("Please try again."),
                dismissButton: .default(.init("Okay"), action: .send(.alertOkayTapped))
            )
        }
                
        scheduler.run()
    }
}
