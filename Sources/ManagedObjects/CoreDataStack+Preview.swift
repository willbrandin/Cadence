import Foundation
import CoreDataStack

public extension CoreDataStack {
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

