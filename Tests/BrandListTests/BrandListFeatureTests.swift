import Combine
import ComposableArchitecture
import XCTest

@testable import BrandListFeature

class BrandListFeatureTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    func testBrandsRequest_Success() {
        var environment = BrandListEnvironment()
        
        environment.mainQueue = self.testScheduler.eraseToAnyScheduler()
        environment.brandClient.requestBrands = {
            Effect(value: .brandList)
        }
        
        let store = TestStore(
            initialState: BrandListState(userSettings: .init()),
            reducer: brandListReducer,
            environment: environment
        )
        
        store.send(.viewLoaded) {
            $0.isBrandRequestInFlight = true
        }
        
        self.testScheduler.advance()
        
        store.receive(.brandsLoaded(.brandList)) {
            $0.isBrandRequestInFlight = false
            $0.brands = .brandList
            $0.filteredBrands = .brandList
            $0.selectedBrand = nil
        }
        
        self.testScheduler.run()
    }
    
    func testSelectBrand() {
        var environment = BrandListEnvironment()
        
        environment.mainQueue = .failing
        environment.brandClient.requestBrands = {
            .failing("BrandClient.RequestBrands")
        }
        
        let store = TestStore(
            initialState: BrandListState(
                brands: .brandList,
                filteredBrands: .brandList,
                userSettings: .init()
            ),
            reducer: brandListReducer,
            environment: environment
        )
        
        store.send(.viewLoaded)
        
        store.send(.setSelected(brand: .shimano)) {
            $0.selectedBrand = .shimano
        }
    }
    
    func testQueryBrands() {
        var environment = BrandListEnvironment()
        
        environment.mainQueue = .failing
        environment.brandClient.requestBrands = {
            .failing("BrandClient.RequestBrands")
        }
        
        let store = TestStore(
            initialState: BrandListState(
                brands: .brandList,
                filteredBrands: .brandList,
                userSettings: .init()
            ),
            reducer: brandListReducer,
            environment: environment
        )
        
        store.send(.viewLoaded)
        
        store.send(.binding(.set(\.$filterQuery, "s"))) {
            $0.filterQuery = "s"
            $0.filteredBrands = [
                .shimano, .sram, .specialized
            ]
        }
        
        store.send(.binding(.set(\.$filterQuery, "shim"))) {
            $0.filterQuery = "shim"
            $0.filteredBrands = [.shimano]
        }
        
        store.send(.binding(.set(\.$filterQuery, ""))) {
            $0.filterQuery = ""
            $0.filteredBrands = .brandList
        }
    }
}
