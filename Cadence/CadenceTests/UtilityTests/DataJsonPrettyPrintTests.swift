import XCTest
import CustomDump

@testable import Cadence

class DataJsonPrettyPrintTests: XCTestCase {
    func testPrettyPrint() {
        let model = Mileage.okay
        let data = model.toJSONData()!
        let prettyString = String(data.prettyPrintedJSONString!)
        
        let expected =
        """
        {
          "id" : "00000000-0000-0000-0000-000000000000",
          "miles" : 270,
          "recommendedMiles" : 500
        }
        """
        
        XCTAssertNoDifference(prettyString, expected)
    }
}
