import CoreData
import ComposableArchitecture
import CoreDataStack

public struct CloudKitClient {
    public var isCloudSyncOn: () -> Bool
    public var setPersistantStore: (Bool) -> Effect<Never, Never>
}

public extension CloudKitClient {
    static var noop: Self {
        Self(
            isCloudSyncOn: { true },
            setPersistantStore: { _ in .none }
        )
    }
}

public extension CloudKitClient {
    static var live: Self {
        Self(
            isCloudSyncOn: {
                return NSUbiquitousKeyValueStore.default.bool(forKey: "icloud_sync")
            },
            setPersistantStore: { cloudSyncOn in
                .fireAndForget {
                    NSUbiquitousKeyValueStore.default.set(cloudSyncOn, forKey: "icloud_sync")
                    CoreDataStack.shared.container = CoreDataStack.setupContainer(withSync: cloudSyncOn)
                }
            }
        )
    }
}
