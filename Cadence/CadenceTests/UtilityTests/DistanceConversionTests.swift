import XCTest
import CustomDump

@testable import Cadence

class DistanceConversionTests: XCTestCase {
    func testMilesToKilometersConversion() {
        var miles: Double = 10
        var converted = DistanceUnit.convert(from: .miles, value: miles)
        var expected = 6.0
        
        XCTAssertNoDifference(converted, expected)
        
        miles = 100
        converted = DistanceUnit.convert(from: .miles, value: miles)
        expected = 62.0
        
        XCTAssertNoDifference(converted, expected)
        
        miles = 1_837
        converted = DistanceUnit.convert(from: .miles, value: miles)
        expected = 1_141.0
        
        XCTAssertNoDifference(converted, expected)
    }
    
    func testKilometersToMilesConversion() {
        var kilometers: Double = 10
        var converted = DistanceUnit.convert(from: .kilometers, value: kilometers)
        var expected = 16.0
        
        XCTAssertNoDifference(converted, expected)
        
        kilometers = 100
        converted = DistanceUnit.convert(from: .kilometers, value: kilometers)
        expected = 161.0
        
        XCTAssertNoDifference(converted, expected)
        
        kilometers = 1_837
        converted = DistanceUnit.convert(from: .kilometers, value: kilometers)
        expected = 2956.0
        
        XCTAssertNoDifference(converted, expected)
    }
    
    func testTextProperties() {
        let abbreviations = ["mi", "km"]
        
        DistanceUnit.allCases.enumerated().forEach {
            XCTAssertNoDifference($1.abbreviation, abbreviations[$0])
        }
        
        let titles = ["miles", "kilometers"]
        
        DistanceUnit.allCases.enumerated().forEach {
            XCTAssertNoDifference($1.title, titles[$0])
        }
    }
    
    func testRounding() {
        let value = 16.1234
        var rounded = RoundingPrecision.preciseRound(value, precision: .ones)
        var expected: Double = 16
        
        XCTAssertNoDifference(rounded, expected)
        
        rounded = RoundingPrecision.preciseRound(value, precision: .tenths)
        expected = 16.1
        
        XCTAssertNoDifference(rounded, expected)

        rounded = RoundingPrecision.preciseRound(value, precision: .hundredths)
        expected = 16.12
        
        XCTAssertNoDifference(rounded, expected)
    }
}
