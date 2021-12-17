import Foundation

final class BundleConfiguration: NSObject {
    /// App Version ie. 4.3.1
    static var appShortVersionString: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    /// Build number for app. ie. 4.1.0 *(6)*
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
    
    static var appDisplayName: String {
        return Bundle.main.infoDictionary?["CFBundleName", default: ""] as? String ?? ""
    }
    
    static var appId: String {
        return Bundle.main.infoDictionary?["CFBundleIdentifier", default: ""] as? String ?? ""
    }
}
