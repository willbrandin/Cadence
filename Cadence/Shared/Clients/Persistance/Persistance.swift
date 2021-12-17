import CoreData
import ComposableArchitecture

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    typealias ObjectType = NSManagedObject
    typealias PredicateType = NSPredicate
    
    var container: NSPersistentCloudKitContainer
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Cadence")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("###\(#function): Failed to retrieve a persistent store description.")
        }
        
        print("cloudkit container identifier : \(description.cloudKitContainerOptions?.containerIdentifier ?? "")")

        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        if(!NSUbiquitousKeyValueStore.default.bool(forKey: "icloud_sync")){
            description.cloudKitContainerOptions = nil
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    static func setupContainer(withSync iCloudSync: Bool) -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: "Cadence")
       
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("###\(#function): Failed to retrieve a persistent store description.")
        }
        
        print("cloudkit container identifier : \(description.cloudKitContainerOptions?.containerIdentifier ?? "")")

        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        if(!iCloudSync){
            description.cloudKitContainerOptions = nil
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }
}

extension CoreDataStack {
    static var preview: CoreDataStack = {
        let result = CoreDataStack(inMemory: true)
        let viewContext = result.context
        
        let brand = BrandMO(context: viewContext)
        brand.id = 2
        brand.isComponentOnly = false
        brand.name = "Yeti"
        
        let compBrand = BrandMO(context: viewContext)
        compBrand.id = 3
        compBrand.isComponentOnly = true
        compBrand.name = "Shimano"
        
        let mileage = MileageMO(context: viewContext)
        mileage.id = UUID()
        mileage.miles = 250
        mileage.recommendedMiles = 500
        
        let compMileage = MileageMO(context: viewContext)
        compMileage.id = UUID()
        compMileage.miles = 250
        compMileage.recommendedMiles = 500
        
        let component = ComponentMO(context: viewContext)
        component.id = UUID()
        component.brand = compBrand
        component.mileage = compMileage
        component.addedToBikeDate = Date()
        component.componentDescription = "Rear derailleur"
        component.model = "SLX"
        component.componentTypeId = 9
        component.componentGroupId = 2
        component.maintenances = []
        
        let bike = BikeMO(context: viewContext)
        bike.id = UUID()
        bike.name = "Yeti 165 Carbon"
        bike.brand = brand
        bike.mileage = mileage
        bike.components = [component]
        bike.maintenances = []
        bike.rides = []
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}

extension CoreDataStack {
    
    func create<T: NSManagedObject>(_ object: T) -> Result<T, Error> {
        do {
            try context.save()
            return .success(object)
        } catch {
            print(error)
            return .failure(error)
        }
    }
    
    func fetch<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate? = nil, limit: Int? = nil) -> Result<[T], Error> {
        let request = NSFetchRequest<T>(entityName: String(describing: objectType))
        request.predicate = predicate
        if let limit = limit {
            request.fetchLimit = limit
        }
        do {
            let result = try context.fetch(request)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func fetchFirst<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate?) -> Result<T?, Error> {
        let request = NSFetchRequest<T>(entityName: String(describing: objectType))
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request)
            return .success(result.first)
        } catch {
            return .failure(error)
        }
    }
    
    func update<T: NSManagedObject>(_ object: T) -> Result<T, Error> {
        do {
            try context.save()
            return .success(object)
        } catch {
            print(error)
            return .failure(error)
        }
    }
    
    func batchUpdate<T: NSManagedObject>(_ objectType: T.Type, _ properties: [AnyHashable: Any], predicate: NSPredicate?) -> Result<[T], Error> {
        let request = NSBatchUpdateRequest(entityName: String(describing: objectType))
        request.propertiesToUpdate = properties
        request.predicate = predicate
        request.resultType = .updatedObjectIDsResultType
      
        do {
            
            let objectIDs = try context.execute(request) as! NSBatchUpdateResult
            let objects = objectIDs.result as! [NSManagedObjectID]
            
            objects.forEach({ objID in
                let managedObject = context.object(with: objID)
                context.refresh(managedObject, mergeChanges: false)
            })
            
            saveContext()
            
            return fetch(T.self, predicate: predicate, limit: nil)
            
        }catch {
            return .failure(error)
        }
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
        
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
