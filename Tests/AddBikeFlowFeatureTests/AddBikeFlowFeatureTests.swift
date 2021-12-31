import Combine
import ComposableArchitecture
import XCTest
import Models

@testable import SaveNewBikeFeature
@testable import AddBikeFlowFeature

class AddBikeFlowFeatureTests: XCTestCase {
    
    func testAddBikeFlow() {
        let id = UUID()
        var newYeti = Bike.yetiMountain
        newYeti.id = id
        newYeti.components = []
        newYeti.mileage = .base
        newYeti.maintenances = nil
        
        var environment = AddBikeFlowEnvironment(
            brandClient: .alwaysFailing,
            bikeClient: .failing,
            mainQueue: .failing
        )
        
        let scheduler = DispatchQueue.test
        
        environment.mainQueue = scheduler.eraseToAnyScheduler()
        
        environment.brandClient.requestBrands = {
            Effect(value: .brandList)
        }
        
        environment.bikeClient.create = { bike in
            XCTAssertNoDifference(bike, newYeti)
            return Effect(value: newYeti)
        }
        
        environment.uuid = { id }
        
        let store = TestStore(
            initialState: AddBikeFlowState(),
            reducer: addBikeFlowReducer,
            environment: environment
        )
        
        store.send(.bikeType(.set(\.$selectedBikeType, .mountain))) {
            $0.selectedBikeType = .mountain
            $0.isBrandNavigationActive = true
        }
        
        store.send(.brandList(.viewLoaded)) {
            $0.brandSelectionState.isBrandRequestInFlight = true
        }
        
        scheduler.advance()
        
        store.receive(.brandList(.brandsLoaded(.brandList))) {
            $0.brandSelectionState.isBrandRequestInFlight = false
            $0.brandSelectionState.filteredBrands = .bikeOnlyBrands
            $0.brandSelectionState.brands = .bikeOnlyBrands
        }
                
        store.send(.brandList(.setSelected(brand: .yeti))) {
            $0.brandSelectionState.selectedBrand = .yeti
            $0.saveNewBikeState = SaveNewBikeState(bikeType: .mountain, bikeBrand: .yeti, mileage: .base)
            $0.isSaveBikeNavigationActive = true
        }
        
        store.send(.saveBike(.set(\.$bikeName, newYeti.name))) {
            $0.saveNewBikeState?.bikeName = newYeti.name
        }
        
        store.send(.saveBike(.saveBike))
        
        scheduler.advance()
        
        store.receive(.saveBike(.saveBikeResponse(.success(newYeti)))) {
            $0.saveNewBikeState?.isSaveBikeRequestInFlight = false
        }
        
        store.receive(.saveBike(.bikeSaved(newYeti)))
        store.receive(.flowComplete(newYeti))
        
        scheduler.run()
    }
}
