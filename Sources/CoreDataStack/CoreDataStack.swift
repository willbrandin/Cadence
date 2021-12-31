import CoreData

public class CoreDataStack {
    
    public static let shared = CoreDataStack()
        
    public var container: NSPersistentCloudKitContainer
    
    public var context: NSManagedObjectContext {
        return container.viewContext
    }

    public init(inMemory: Bool = false) {
        container = Self.setupCloudKitContainer(withSync: true, inMemory: inMemory)
    }
    
    public static func setupContainer(withSync iCloudSync: Bool) -> NSPersistentCloudKitContainer {
        return Self.setupCloudKitContainer(withSync: iCloudSync)
    }
    
    internal static func setupCloudKitContainer(withSync: Bool, inMemory: Bool = false) -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: "Cadence", managedObjectModel: cadenceModel)
       
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("###\(#function): Failed to retrieve a persistent store description.")
        }
        
        print("cloudkit container identifier : \(description.cloudKitContainerOptions?.containerIdentifier ?? "")")

        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)
        
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        if !withSync {
            description.cloudKitContainerOptions = nil
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }
}
