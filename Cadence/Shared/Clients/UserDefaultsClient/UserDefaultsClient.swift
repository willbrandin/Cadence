import Foundation
import ComposableArchitecture

struct UserDefaultsKey {
    static let didFinishOnboardingKey = "didFinishOnboardingKey"
}

public struct UserDefaultsClient {
    public var boolForKey: (String) -> Bool
    public var dataForKey: (String) -> Data?
    public var doubleForKey: (String) -> Double
    public var integerForKey: (String) -> Int
    public var remove: (String) -> Effect<Never, Never>
    public var setBool: (Bool, String) -> Effect<Never, Never>
    public var setData: (Data?, String) -> Effect<Never, Never>
    public var setDouble: (Double, String) -> Effect<Never, Never>
    public var setInteger: (Int, String) -> Effect<Never, Never>
    public var clear: () -> Effect<Never, Never>
    
    public var hasShownFirstLaunchOnboarding: Bool {
        self.boolForKey(UserDefaultsKey.didFinishOnboardingKey)
    }
    
    public func setHasShownFirstLaunchOnboarding(_ bool: Bool) -> Effect<Never, Never> {
        self.setBool(bool, UserDefaultsKey.didFinishOnboardingKey)
    }
}
