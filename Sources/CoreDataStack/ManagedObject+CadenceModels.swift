import Foundation
import Combine
import Models
import World

public extension _MileageMO {
    static func initFrom(_ mileage: Mileage) -> _MileageMO {
        let context = Current.coreDataStack().context
        let mileageMO = _MileageMO(context: context)

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

public extension _BikeMO {
    static func initFrom(_ bike: Bike) -> _BikeMO {
        let context = Current.coreDataStack().context
        let managedObject = _BikeMO(context: context)
        
        managedObject.name = bike.name
        managedObject.id = bike.id
        managedObject.brand = _BrandMO.initFrom(bike.brand)
        managedObject.bikeTypeId = Int16(bike.bikeTypeId.rawValue)
        managedObject.components = NSSet(array: bike.components.map { _ComponentMO.initFrom($0) } )
        managedObject.maintenances = NSSet(array: bike.maintenances?.compactMap { _MaintenanceMO.initFrom($0) } ?? [])
        managedObject.mileage = _MileageMO.initFrom(bike.mileage)
        managedObject.rides = NSSet(array: bike.rides.map { _RideMO.initFrom($0) } )

        return managedObject
    }
    
    func asBike() -> Bike {
        Bike(id: self.id!,
             name: self.name!,
             components: Array(self.components as! Set<_ComponentMO>).map({ $0.asComponent() }),
             bikeTypeId: BikeType(rawValue: Int(exactly: self.bikeTypeId)!) ?? .mountain,
             mileage: self.mileage!.asMileage(),
             maintenances: Array(self.maintenances as? Set<_MaintenanceMO> ?? []).map({ $0.asMaintenance() }),
             brand: self.brand!.asBrand(),
             rides: Array(self.rides as? Set<_RideMO> ?? []).map({ $0.asRide() })
        )
    }
}

public extension _ComponentMO {
    static func initFrom(_ component: Component) -> _ComponentMO {
        let context = Current.coreDataStack().context
        let managedObject = _ComponentMO(context: context)
        
        managedObject.id = component.id
        managedObject.brand = _BrandMO.initFrom(component.brand)
        managedObject.mileage = _MileageMO.initFrom(component.mileage)
        managedObject.addedToBikeDate = component.addedToBikeDate
        managedObject.componentDescription = component.description
        managedObject.model = component.model
        managedObject.componentTypeId = Int16(component.componentTypeId.rawValue)
        managedObject.componentGroupId = Int16(component.componentGroupId.rawValue)
        managedObject.maintenances = NSSet(array: component.maintenances.map { _MaintenanceMO.initFrom($0) } )
        
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
            maintenances: Array(self.maintenances as? Set<_MaintenanceMO> ?? []).map({ $0.asMaintenance() }),
            brand: self.brand!.asBrand()
        )
    }
}

public extension _MaintenanceMO {
    static func initFrom(_ service: Maintenance) -> _MaintenanceMO {
        let context = Current.coreDataStack().context
        let managedObject = _MaintenanceMO(context: context)
        
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

public extension _BrandMO {
    static func initFrom(_ brand: Brand) -> _BrandMO {
        let context = Current.coreDataStack().context
        let managedObject = _BrandMO(context: context)
        
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

public extension _RideMO {
    static func initFrom(_ ride: Ride) -> _RideMO {
        let context = Current.coreDataStack().context
        let managedObject = _RideMO(context: context)

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
