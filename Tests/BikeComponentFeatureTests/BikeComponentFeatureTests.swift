import AddComponentFlowFeature
import Combine
import ComposableArchitecture
import ComponentDetailFeature
import Models
import XCTest

@testable import BikeComponentListFeature

class BikeComponentFeatureTests: XCTestCase {
    
    func testSetComponentFlowActive() {
        let store = TestStore(
            initialState: BikeComponentState(bike: .yetiMountain),
            reducer: bikeComponentReducer,
            environment: BikeComponentEnvironment()
        )

        store.send(.setComponentFlowNavigation(isActive: true)) {
            $0.isAddComponentFlowNavigationActive = true
            $0.addComponentFlowState = AddComponentFlowState(bikeId: Bike.yetiMountain.id)
        }
        
        store.send(.addComponentFlow(.didTapCloseFlow))
        
        store.receive(.setComponentFlowNavigation(isActive: false)) {
            $0.isAddComponentFlowNavigationActive = false
            $0.addComponentFlowState = nil
        }
    }
    
    func testComponentFlowDidComplete() {
        let store = TestStore(
            initialState: BikeComponentState(
                bike: .specializedMountain
            ),
            reducer: bikeComponentReducer,
            environment: BikeComponentEnvironment()
        )
        
        store.send(.setComponentFlowNavigation(isActive: true)) {
            $0.isAddComponentFlowNavigationActive = true
            $0.addComponentFlowState = AddComponentFlowState(bikeId: Bike.specializedMountain.id)
        }
        
        store.send(.addComponentFlow(.flowComplete(.racefaceCarbon69Handlebars))) {
            $0.bike.components = [
                .shimanoSLXBrakes,
                .shimanoXLTBrakeRotor,
                .racefaceCogsette,
                .wtbFrontWheelSet,
                .racefaceCarbon69Handlebars
            ]
        }
        
        store.receive(.setComponentFlowNavigation(isActive: false)) {
            $0.isAddComponentFlowNavigationActive = false
            $0.addComponentFlowState = nil
        }
    }
    
    func testSetBikeOptionsSheetActive() {
        let store = TestStore(
            initialState: BikeComponentState(bike: .yetiMountain),
            reducer: bikeComponentReducer,
            environment: BikeComponentEnvironment()
        )
        
        store.send(.setBikeOptionSheet(isActive: true)) {
            $0.isBikeOptionSheetActive = true
        }
    }
    
    func testSelectedComponent() {
       
        let bike = Bike.yetiMountain
        
        let store = TestStore(
            initialState: BikeComponentState(
                bike: bike
            ),
            reducer: bikeComponentReducer,
            environment: BikeComponentEnvironment()
        )
        
        store.send(.setNavigation(selection: Component.racefaceCarbon69Handlebars.id)) {
            $0.selection = Identified(
                ComponentDetailState(component: Component.racefaceCarbon69Handlebars, bikeComponents: bike.components),
                id: Component.racefaceCarbon69Handlebars.id
            )
        }
        
        store.send(.setNavigation(selection: .none)) {
            $0.selection = nil
        }
    }
}
