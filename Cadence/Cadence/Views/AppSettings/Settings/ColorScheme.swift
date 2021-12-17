import UIKit

enum ColorScheme: String, CaseIterable, Codable, Equatable {
    case dark
    case light
    case system
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return .unspecified
        }
    }
    
    var title: String {
        switch self {
        case .dark:
            return "Dark"
        case .light:
            return "Light"
        case .system:
            return "System (Default)"
        }
    }
}
