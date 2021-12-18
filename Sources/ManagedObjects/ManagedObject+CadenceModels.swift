import Foundation
import Combine
import Models
import World

public extension MileageMO {
    static func initFrom(_ mileage: Mileage) -> MileageMO {
        let context = Current.coreDataStack().context
        let mileageMO = MileageMO(context: context)

        mileageMO.id = mileage.id
        mileageMO.miles = Int16(mileage.miles)
        mileageMO.recommendedMiles = Int16(mileage.recommendedMiles)

        return mileageMO
    }
    
    func asMileage() -> Mileage {
        Mileage(
            id: self.id!,
            miles: Int(self.miles),
            recommendedMiles: Int(self.recommendedMiles)
        )
    }
}

public extension BikeMO {
    static func initFrom(_ bike: Bike) -> BikeMO {
        let context = Current.coreDataStack().context
        let managedObject = BikeMO(context: context)
        
        managedObject.name = bike.name
        managedObject.id = bike.id
        managedObject.brand = BrandMO.initFrom(bike.brand)
        managedObject.bikeTypeId = Int16(bike.bikeTypeId.rawValue)
        managedObject.components = NSSet(array: bike.components.map { ComponentMO.initFrom($0) } )
        managedObject.maintenances = NSSet(array: bike.maintenances?.compactMap { MaintenanceMO.initFrom($0) } ?? [])
        managedObject.mileage = MileageMO.initFrom(bike.mileage)
        managedObject.rides = NSSet(array: bike.rides.map { RideMO.initFrom($0) } )

        return managedObject
    }
    
    func asBike() -> Bike {
        Bike(id: self.id!,
             name: self.name!,
             components: Array(self.components as! Set<ComponentMO>).map({ $0.asComponent() }),
             bikeTypeId: BikeType(rawValue: Int(exactly: self.bikeTypeId)!) ?? .mountain,
             mileage: self.mileage!.asMileage(),
             maintenances: Array(self.maintenances as? Set<MaintenanceMO> ?? []).map({ $0.asMaintenance() }),
             brand: self.brand!.asBrand(),
             rides: Array(self.rides as? Set<RideMO> ?? []).map({ $0.asRide() })
        )
    }
}

public extension ComponentMO {
    static func initFrom(_ component: Component) -> ComponentMO {
        let context = Current.coreDataStack().context
        let managedObject = ComponentMO(context: context)
        
        managedObject.id = component.id
        managedObject.brand = BrandMO.initFrom(component.brand)
        managedObject.mileage = MileageMO.initFrom(component.mileage)
        managedObject.addedToBikeDate = component.addedToBikeDate
        managedObject.componentDescription = component.description
        managedObject.model = component.model
        managedObject.componentTypeId = Int16(component.componentTypeId.rawValue)
        managedObject.componentGroupId = Int16(component.componentGroupId.rawValue)
        managedObject.maintenances = NSSet(array: component.maintenances.map { MaintenanceMO.initFrom($0) } )
        
        return managedObject
    }
    
    func asComponent() -> Component {
        Component(
            id: self.id!,
            model: self.model,
            description: self.componentDescription,
            componentTypeId: ComponentType(rawValue: Int(exactly: self.componentTypeId) ?? 0) ?? .other,
            componentGroupId: ComponentGroup(rawValue: Int(exactly: self.componentGroupId) ?? 0) ?? .miscellaneus,
            addedToBikeDate: self.addedToBikeDate!,
            mileage: self.mileage!.asMileage(),
            maintenances: Array(self.maintenances as? Set<MaintenanceMO> ?? []).map({ $0.asMaintenance() }),
            brand: self.brand!.asBrand()
        )
    }
}

public extension MaintenanceMO {
    static func initFrom(_ service: Maintenance) -> MaintenanceMO {
        let context = Current.coreDataStack().context
        let managedObject = MaintenanceMO(context: context)
        
        managedObject.id = service.id
        managedObject.serviceDate = service.serviceDate
        managedObject.serviceDescription = service.description
        
        return managedObject
    }
    
    func asMaintenance() -> Maintenance {
        Maintenance(
            id: self.id!,
            description: self.serviceDescription,
            serviceDate: self.serviceDate!
        )
    }
}

public extension BrandMO {
    static func initFrom(_ brand: Brand) -> BrandMO {
        let context = Current.coreDataStack().context
        let managedObject = BrandMO(context: context)
        
        managedObject.id = Int16(brand.id)
        managedObject.isComponentOnly = brand.isComponentManufacturerOnly
        managedObject.name = brand.brand
        
        return managedObject
    }
    
    func asBrand() -> Brand {
        Brand(
            id: Int(self.id),
            brand: self.name!,
            isComponentManufacturerOnly: self.isComponentOnly
        )
    }
}

public extension RideMO {
    static func initFrom(_ ride: Ride) -> RideMO {
        let context = Current.coreDataStack().context
        let managedObject = RideMO(context: context)

        managedObject.id = ride.id
        managedObject.date = ride.date
        managedObject.distance = Int16(ride.distance)
        
        return managedObject
    }
    
    func asRide() -> Ride {
        Ride(
            id: self.id!,
            date: self.date!,
            distance: Int(self.distance)
        )
    }
}
