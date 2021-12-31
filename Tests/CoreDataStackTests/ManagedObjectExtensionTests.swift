import XCTest
import Models
import World
@testable import CoreDataStack

class ManagedObjectExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        Current.coreDataStack = {
            CoreDataStack.preview
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testBikeObject() {
        let object = Bike(
            id: .init(),
            name: "Bike",
            components: [],
            bikeTypeId: .mountain,
            mileage: .base,
            maintenances: [],
            brand: .yeti,
            rides: []
        )
        let managedObject = BikeMO.initFrom(object)
        let convertedObject = managedObject.asBike()
        
        XCTAssertEqual(object, convertedObject)
    }
    
    func testBrandObject() {
        let object = Brand.yeti
        let managedObject = BrandMO.initFrom(object)
        let convertedObject = managedObject.asBrand()
        
        XCTAssertEqual(object, convertedObject)
    }
    
    func testComponentObject() {
        let object = Component.canyonFrame
        let managedObject = ComponentMO.initFrom(object)
        let convertedObject = managedObject.asComponent()
        
        XCTAssertEqual(object, convertedObject)
    }
    
    func testMaintenanceObject() {
        let object = Maintenance(id: .init(), description: "Description", serviceDate: .distantPast)
        let managedObject = MaintenanceMO.initFrom(object)
        let convertedObject = managedObject.asMaintenance()
        
        XCTAssertEqual(object, convertedObject)
    }
    
    func testMileageObject() {
        let object = Mileage(id: .init(), miles: 125, recommendedMiles: 500)
        let managedObject = MileageMO.initFrom(object)
        let convertedObject = managedObject.asMileage()
        
        XCTAssertEqual(object, convertedObject)
    }
    
    func testRideObject() {
        let object = Ride(id: .init(), date: .distantPast, distance: 10)
        let managedObject = RideMO.initFrom(object)
        let convertedObject = managedObject.asRide()
        
        XCTAssertEqual(object, convertedObject)
    }
}
