import CoreData
import ComposableArchitecture

struct CloudKitClient {
    var isCloudSyncOn: () -> Bool
    var setPersistantStore: (Bool) -> Effect<Never, Never>
}

extension CloudKitClient {
    static var noop: Self {
        Self(
            isCloudSyncOn: { true },
            setPersistantStore: { _ in .none }
        )
    }
}

extension CloudKitClient {
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
