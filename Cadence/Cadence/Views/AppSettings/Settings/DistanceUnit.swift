import Foundation

enum DistanceUnit: Int, Codable, Equatable, CaseIterable {
    case miles = 1
    case kilometers
    
    var title: String {
        switch self {
        case .miles: return "miles"
        case .kilometers: return "kilometers"
        }
    }
    
    var abbreviation: String {
        switch self {
        case .miles: return "mi"
        case .kilometers: return "km"
        }
    }
    
    static func convert(to unit: DistanceUnit, value: Double) -> Double {
        switch unit {
        case .kilometers:
            return convertMilesToKilometers(miles: value)
        case .miles:
            return convertKilometersToMiles(kilometers: value)
        }
    }
    
    static func convert(from unit: DistanceUnit, value: Double) -> Double {
        switch unit {
        case .miles:
            return convertMilesToKilometers(miles: value)
        case .kilometers:
            return convertKilometersToMiles(kilometers: value)
        }
    }
    
    static func convertMilesToKilometers(miles: Double) -> Double {
        let result = (miles * 0.621371)
        return RoundingPrecision.preciseRound(result)
    }
    
    static func convertKilometersToMiles(kilometers: Double) -> Double {
        let result = (kilometers * 1.609344)
        return RoundingPrecision.preciseRound(result)
    }
}

enum RoundingPrecision {
    case ones
    case tenths
    case hundredths
    
    
    // Round to the specific decimal place
    static func preciseRound(
        _ value: Double,
        precision: RoundingPrecision = .ones) -> Double
    {
        switch precision {
        case .ones:
            return round(value)
        case .tenths:
            return round(value * 10) / 10.0
        case .hundredths:
            return round(value * 100) / 100.0
        }
    }
}
