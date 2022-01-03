import ComposableArchitecture
import Models
import XCTest
import AddCustomBrandFeature
import BrandClient
import World

class AddCustomBrandFeatureTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        Current.randomNumber = { Int.random(in: 200..<500) }
    }
    
    func testAddBrand() {
        var environment = AddBrandEnvironment.failing
        let scheduler = DispatchQueue.test
        
        let addedBrand = Brand(id: 999, brand: "Owenhouse", isComponentManufacturerOnly: true)
        
        environment.mainQueue = scheduler.eraseToAnyScheduler()
        
        environment.brandClient.createUserBrand = { brand in
            guard brand == addedBrand
            else { return .failing("Added Brand does not match expecation") }
            return Effect(value: brand)
        }
        
        Current.randomNumber = { return 999 }
        
        let store = TestStore(
            initialState: AddBrandState(),
            reducer: addBrandReducer,
            environment: environment
        )
        
        store.send(.set(\.$brandName, "Owenhouse")) {
            $0.brandName = "Owenhouse"
        }
        
        store.send(.set(\.$isComponentOnly, true)) {
            $0.isComponentOnly = true
        }
        
        store.send(.saveButtonTapped)
        
        scheduler.advance()
        
        store.receive(.saveBrandResponse(.success(addedBrand)))
        store.receive(.didAddBrand(addedBrand))
        
        scheduler.run()
    }
    
    func testAddEmptyName() {
        let environment = AddBrandEnvironment.failing
        
        let store = TestStore(
            initialState: AddBrandState(),
            reducer: addBrandReducer,
            environment: environment
        )
        
        store.send(.set(\.$isComponentOnly, true)) {
            $0.isComponentOnly = true
        }
        
        store.send(.saveButtonTapped) {
            $0.alert = AlertState(
                title: .init("Brand name cannot be empty"),
                message: nil,
                dismissButton: .default(.init("Okay"), action: .send(.alertOkayTapped))
            )
        }
        
        store.send(.alertOkayTapped) {
            $0.alert = nil
        }
    }
    
    func testFailingClient() {
        var environment = AddBrandEnvironment.failing
        let scheduler = DispatchQueue.test
                    
        environment.mainQueue = scheduler.eraseToAnyScheduler()
        
        let failure = BrandClient.Failure()
        
        environment.brandClient.createUserBrand = { _ in
            return Effect(error: failure)
        }
        
        let store = TestStore(
            initialState: AddBrandState(),
            reducer: addBrandReducer,
            environment: environment
        )
        
        store.send(.set(\.$brandName, "Owenhouse")) {
            $0.brandName = "Owenhouse"
        }
        
        store.send(.set(\.$isComponentOnly, true)) {
            $0.isComponentOnly = true
        }
        
        store.send(.saveButtonTapped)
        
        scheduler.advance()
        
        store.receive(.saveBrandResponse(.failure(failure))) {
            $0.alert = AlertState(
                title: .init("Sorry, could not save brand."),
                message: .init("Please try again."),
                dismissButton: .default(.init("Okay"), action: .send(.alertOkayTapped))
            )
        }
        
        scheduler.run()
    }
}
