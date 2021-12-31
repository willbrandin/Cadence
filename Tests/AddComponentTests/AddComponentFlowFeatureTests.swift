import Combine
import ComposableArchitecture
import Models
import XCTest

import TypeSelectionFeature
import CreateComponentFeature

@testable import AddComponentFlowFeature

private var component = Component.shimanoSLXRearDerailleur

class AddComponentFlowFeatureTests: XCTestCase {
    
    func testAddComponentFlow() {
        let today = Date.distantPast

        var environment = AddComponentFlowEnvironment(
            brandClient: .alwaysFailing,
            componentClient: .failing,
            mainQueue: .failing,
            date: { today }
        )

        let scheduler = DispatchQueue.test

        environment.mainQueue = scheduler.eraseToAnyScheduler()

        environment.brandClient.requestBrands = {
            Effect(value: .brandList)
        }

        environment.uuid = { Component.shimanoSLXRearDerailleur.id }

        environment.componentClient.create = { _, newComponent in
            guard newComponent.model == component.model,
                  newComponent.description == component.description,
                  newComponent.brand == component.brand,
                  newComponent.componentTypeId == component.componentTypeId,
                  newComponent.componentGroupId == component.componentGroupId,
                  newComponent.addedToBikeDate == component.addedToBikeDate
            else { return .failing("ComponentClient.addComponent - Components are not equal") }

            return Effect(value: newComponent)
        }

        let store = TestStore(
            initialState: AddComponentFlowState(bikeId: Bike.yetiMountain.id),
            reducer: addComponentFlowReducer,
            environment: environment
        )

        store.send(.groupSelection(.binding(.set(\.$selectedComponentGroupType, .drivetrain)))) {
            $0.groupSelectionState.selectedComponentGroupType = .drivetrain
            $0.isTypeSelectionNavigationActive = true
        }

        store.send(.typeSelection(.binding(.set(\.$selectedComponentType, .derailleur)))) {
            $0.typeSelectionState.selectedComponentType = .derailleur
            $0.isBrandNavigationActive = true
        }

        store.send(.brandList(.viewLoaded)) {
            $0.brandListState.isBrandRequestInFlight = true
        }

        scheduler.advance()

        store.receive(.brandList(.brandsLoaded(.brandList)))  {
            $0.brandListState.isBrandRequestInFlight = false
            $0.brandListState.filteredBrands = .brandList
            $0.brandListState.brands = .brandList
        }

        store.send(.brandList(.setSelected(brand: .shimano))) {
            $0.brandListState.selectedBrand = .shimano

            $0.componentDetailState = CreateComponentState(
                date: today,
                bikeId: Bike.yetiMountain.id,
                brand: .shimano,
                componentGroup: .drivetrain,
                componentType: .derailleur
            )

            $0.isComponentDetailNavigationActive = true
        }

        store.send(.componentDetail(.set(\.$isCustomDate, true))) {
            $0.componentDetailState?.isCustomDate = true
        }

        store.send(.componentDetail(.set(\.$date, component.addedToBikeDate))) {
            $0.componentDetailState?.date = component.addedToBikeDate
        }

        store.send(.componentDetail(.set(\.$model, component.model!))) {
            $0.componentDetailState?.model = component.model!
        }

        store.send(.componentDetail(.set(\.$description, component.description!))) {
            $0.componentDetailState?.description = component.description!
        }

        store.send(.componentDetail(.didTapSave)) {
            $0.componentDetailState?.isCreateComponentRequestInFlight = true
        }

        scheduler.advance()

        component.mileage.miles = 0
        component.mileage.id = Component.shimanoSLXRearDerailleur.id

        store.receive(.componentDetail(.componentSavedResponse(.success(component)))) {
            $0.componentDetailState?.isCreateComponentRequestInFlight = false
        }

        store.receive(.componentDetail(.componentSaved(component)))
        store.receive(.flowComplete(component))

        scheduler.run()
    }
}
