import Combine
import ComposableArchitecture
import XCTest

@testable import Cadence

class CreateComponentFeatureTests: XCTestCase {
    
    func testUpdateComponentModelText() {
        let store = TestStore(
            initialState: CreateComponentState(bikeId: Bike.yetiMountain.id),
            reducer: addComponentReducer,
            environment: CreateComponentEnvironment()
        )
        
        store.send(.binding(.set(\.$model, "Hello"))) {
            $0.model = "Hello"
        }
    }
    
    func testUpdateComponentDescriptionText() {
        let store = TestStore(
            initialState: CreateComponentState(bikeId: Bike.yetiMountain.id),
            reducer: addComponentReducer,
            environment: CreateComponentEnvironment()
        )
        
        store.send(.binding(.set(\.$description, "Hello"))) {
            $0.description = "Hello"
        }
    }
    
    func testUpdateDate() {
        // This is "Today's Date" returned from Swift.Date()
        let baseDate = Date.initFromComponents(year: 2021, month: 1, day: 21, hour: 8, minute: 0)!
                
        let updatedDate = Date.initFromComponents(year: 2021, month: 3, day: 19, hour: 8, minute: 0)!
        
        let store = TestStore(
            initialState: CreateComponentState(date: baseDate, bikeId: Bike.yetiMountain.id),
            reducer: addComponentReducer,
            environment: CreateComponentEnvironment(
                date: { baseDate }
            )
        )
                
        store.send(.set(\.$isCustomDate, true)) {
            $0.date = baseDate
            $0.isCustomDate = true
        }
        
        store.send(.binding(.set(\.$date, updatedDate))) {
            $0.date = updatedDate
        }
        
        store.send(.set(\.$isCustomDate, false)) {
            $0.date = baseDate
            $0.isCustomDate = false
        }
        
        store.send(.binding(.set(\.$date, updatedDate))) {
            $0.date = baseDate
        }
    }
    
    func testSaveComponent() {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
        var component = Component(id: id, model: "", description: "", componentTypeId: .cassette, componentGroupId: .drivetrain, addedToBikeDate: .distantPast, mileage: .base, maintenances: [], brand: .sram)
        component.mileage.id = id
        
        var environment = CreateComponentEnvironment.failing
        
        let scheduler = DispatchQueue.test
        
        environment.componentClient.create = { _, savedComponent in
            XCTAssertNoDifference(savedComponent, component)
            
            return Effect(value: savedComponent)
        }
        
        environment.uuid = { id }

        environment.mainQueue = scheduler.eraseToAnyScheduler()
                
        let store = TestStore(
            initialState: CreateComponentState(date: .distantPast, bikeId: Bike.yetiMountain.id),
            reducer: addComponentReducer,
            environment: environment
        )
        
        store.send(.didTapSave) {
            $0.isCreateComponentRequestInFlight = true
        }
        
        scheduler.advance()
        
        store.receive(.componentSavedResponse(.success(component))) {
            $0.isCreateComponentRequestInFlight = false
        }
        
        store.receive(.componentSaved(component))
        
        scheduler.run()
    }
    
    func testSaveComponentFailure() {
        var environment = CreateComponentEnvironment.failing
        
        let scheduler = DispatchQueue.test
        let error: ComponentClient.Failure = .init()
        
        environment.componentClient.create = { _, _ in
            return Effect(error: error)
        }
        
        environment.mainQueue = scheduler.eraseToAnyScheduler()
        
        let store = TestStore(
            initialState: CreateComponentState(date: .distantPast, bikeId: Bike.yetiMountain.id),
            reducer: addComponentReducer,
            environment: environment
        )
        
        store.send(.didTapSave) {
            $0.isCreateComponentRequestInFlight = true
        }
        
        scheduler.advance()
        
        store.receive(.componentSavedResponse(.failure(error))) {
            $0.isCreateComponentRequestInFlight = false
        }
        
        scheduler.run()
    }
    
    func testMileageAlert_Options() {
        let store = TestStore(
            initialState: CreateComponentState(
                bikeId: Bike.yetiMountain.id
            ),
            reducer: addComponentReducer,
            environment: .failing
        )
        
        store.send(.binding(.set(\.$isMileageSettingNavigationActive, true))) {
            $0.isMileageSettingNavigationActive = true
            $0.mileagePickerState = MileagePickerState(selectedOption: .fiveHundred)
        }

        store.send(.mileagePicker(.binding(.set(\.$selectedOption, .oneThousand)))) {
            $0.mileagePickerState?.selectedOption = .oneThousand
        }
        
        store.send(.mileagePicker(.didTapSave)) {
            $0.recommendedMiles = 1000
            $0.isMileageSettingNavigationActive = false
        }
    }
    
    func testMileageAlert_Custom() {
        let store = TestStore(
            initialState: CreateComponentState(bikeId: Bike.yetiMountain.id),
            reducer: addComponentReducer,
            environment: .failing
        )
        
        store.send(.binding(.set(\.$isMileageSettingNavigationActive, true))) {
            $0.isMileageSettingNavigationActive = true
            $0.mileagePickerState = MileagePickerState(selectedOption: .fiveHundred)
        }

        store.send(.mileagePicker(.binding(.set(\.$selectedOption, .custom)))) {
            $0.mileagePickerState?.selectedOption = .custom
            $0.mileagePickerState?.isShowingCustomTextField = true
        }
        
        store.send(.mileagePicker(.binding(.set(\.$customText, "123")))) {
            $0.mileagePickerState?.customText = "123"
        }
        
        store.send(.mileagePicker(.didTapSave)) {
            $0.recommendedMiles = 123
            $0.isMileageSettingNavigationActive = false
        }
        
        store.send(.binding(.set(\.$isMileageSettingNavigationActive, true))) {
            $0.isMileageSettingNavigationActive = true
            $0.mileagePickerState = MileagePickerState(selectedOption: .custom, customText: "123", isShowingCustomTextField: true)
        }
    }
    
    func testMileageAlert_Custom_Empty() {
        let store = TestStore(
            initialState: CreateComponentState(bikeId: Bike.yetiMountain.id),
            reducer: addComponentReducer,
            environment: .failing
        )
        
        store.send(.binding(.set(\.$isMileageSettingNavigationActive, true))) {
            $0.isMileageSettingNavigationActive = true
            $0.mileagePickerState = MileagePickerState(selectedOption: .fiveHundred)
        }

        store.send(.mileagePicker(.binding(.set(\.$selectedOption, .custom)))) {
            $0.mileagePickerState?.selectedOption = .custom
            $0.mileagePickerState?.isShowingCustomTextField = true
        }
        
        store.send(.mileagePicker(.binding(.set(\.$customText, "")))) {
            $0.mileagePickerState?.customText = ""
        }
        
        store.send(.mileagePicker(.didTapSave)) {
            $0.recommendedMiles = 500
            $0.isMileageSettingNavigationActive = false
        }
    }
    
    func testMileageAlert_Custom_Empty_SwitchOption() {
        let store = TestStore(
            initialState: CreateComponentState(bikeId: Bike.yetiMountain.id),
            reducer: addComponentReducer,
            environment: .failing
        )
        
        store.send(.binding(.set(\.$isMileageSettingNavigationActive, true))) {
            $0.isMileageSettingNavigationActive = true
            $0.mileagePickerState = MileagePickerState(selectedOption: .fiveHundred)
        }

        store.send(.mileagePicker(.binding(.set(\.$selectedOption, .custom)))) {
            $0.mileagePickerState?.selectedOption = .custom
            $0.mileagePickerState?.isShowingCustomTextField = true
        }
        
        store.send(.mileagePicker(.binding(.set(\.$customText, "")))) {
            $0.mileagePickerState?.customText = ""
        }
        
        store.send(.mileagePicker(.binding(.set(\.$selectedOption, .oneThousand)))) {
            $0.mileagePickerState?.selectedOption = .oneThousand
            $0.mileagePickerState?.isShowingCustomTextField = false
            $0.mileagePickerState?.customText = ""
        }
        
        store.send(.mileagePicker(.didTapSave)) {
            $0.recommendedMiles = 1000
            $0.isMileageSettingNavigationActive = false
        }
    }
}
