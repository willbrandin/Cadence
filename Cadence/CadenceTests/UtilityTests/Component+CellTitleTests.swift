import XCTest
import CustomDump

@testable import Cadence

class ComponentCellTitleTests: XCTestCase {
    func testComponentCellTitle() {
        var component = Component.shimanoSLXRearDerailleur
        
        var expected = "Rear Derailleur"
        XCTAssertNoDifference(component.cellTitle, expected)
        
        component.description = nil
        expected = "Shimano - SLX"
        XCTAssertNoDifference(component.cellTitle, expected)
        
        component.model = nil
        expected = "Shimano - Derailleur"
        XCTAssertNoDifference(component.cellTitle, expected)
    }
}
