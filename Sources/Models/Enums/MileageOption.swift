import Foundation

public enum MileageOption: Int, CaseIterable, Codable {
    case twoHundredFifty = 250
    case fiveHundred = 500
    case oneThousand = 1_000
    case custom
    
    public var title: String {
        switch self {
        case .twoHundredFifty:
            return "250"
        case .fiveHundred:
            return "500"
        case .oneThousand:
            return "1,000"
        case .custom:
            return "Custom"
        }
    }
}
