import Combine
import ComposableArchitecture
import Models
import XCTest
import World
import AddRideFlowFeature

class AddRideFlowTests: XCTestCase {
    func testAddRide() {
        let baseDate = Date.initFromComponents(year: 2022, month: 1, day: 15, hour: 8, minute: 0)!
        let changedDate = Date.initFromComponents(year: 2022, month: 1, day: 20, hour: 8, minute: 0)!
        
        var environment = AddRideFlowEnvironment.failing
        let scheduler = DispatchQueue.test
        
        environment.mainQueue = scheduler.eraseToAnyScheduler()
        
        environment.date = {
            baseDate
        }
        
        environment.uuid = {
            return .init(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
        }
        
        let createdRide = Ride(
            id: .init(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            date: changedDate,
            distance: 25
        )
        
        environment.rideClient.create = { _, _, ride in
            guard ride == createdRide
            else { return .failing("Rides do not match") }
            
            return Effect(value: ride)
        }
        
        environment.bikeClient.update = { bike in
            return Effect(value: bike)
        }
        
        let store = TestStore(
            initialState: AddRideFlowState(
                selectableBikes: [.specializedMountain, .canyonRoad, .yetiMountain],
                selectedBike: .yetiMountain,
                miles: "",
                date: baseDate,
                userSettings: .init()
            ),
            reducer: addRideReducer,
            environment: environment
        )
        
        store.send(.setSelected(bike: .specializedMountain)) {
            $0.selectedBike = .specializedMountain
        }
        
        store.send(.set(\.$miles, "25")) {
            $0.miles = "25"
        }
        
        store.send(.set(\.$date, changedDate)) {
            $0.date = changedDate
        }
        
        store.send(.saveButtonTapped)
        
        scheduler.advance()
        
        var changedBike = Bike.specializedMountain
        
        changedBike.mileage.miles = changedBike.mileage.miles + 25
        changedBike.components = changedBike.components.map { component in
            var component = component
            component.mileage.miles = component.mileage.miles + 25
            return component
        }
        
        store.receive(.saveRideResponse(.success(createdRide))) {
            $0.selectedBike = changedBike
        }
        
        scheduler.advance()
        
        store.receive(.updateBikeMileageResponse(.success(changedBike)))
        
        scheduler.run()
    }
}
