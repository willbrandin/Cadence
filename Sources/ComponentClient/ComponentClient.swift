import ComposableArchitecture
import Combine
import CoreDataStack
import Models
import World

public struct ComponentClient {
    public struct Failure: Error, Equatable {}

    public var create: (String, Component) -> Effect<Component, ComponentClient.Failure>
    public var update: (Component) -> Effect<Component, ComponentClient.Failure>
    public var batchUpdate: ([AnyHashable: Any], [Component]) -> Effect<[Component], ComponentClient.Failure>
    public var delete: (Component) -> Effect<Never, Never>
}

public extension ComponentClient {
    static var live: Self = Self(
        create: { bikeId, model in
            guard let bike = try? Current.coreDataStack().fetchFirst(_BikeMO.self, predicate: NSPredicate(format: "id == %@", bikeId)).get() else {
                return Effect(error: .init())
            }
            
            let component = _ComponentMO.initFrom(model)
            component.bike = bike
            
            let brand = _BrandMO.initFrom(model.brand)
            component.brand = brand
            
            let mileage = _MileageMO.initFrom(model.mileage)
            component.mileage = mileage
            
            return Current.coreDataStack().create(component)
                .publisher
                .map({ $0.asComponent() })
                .mapError { _ in Failure() }
                .eraseToEffect()
        }, update: { model in
            guard let managedObject = try? Current.coreDataStack().fetchFirst(_ComponentMO.self, predicate: NSPredicate(format: "id == %@", model.id.uuidString)).get() else {
                return Effect(error: .init())
            }
            
            return Current.coreDataStack().update(managedObject)
                .publisher
                .map({ $0.asComponent() })
                .mapError { _ in Failure() }
                .eraseToEffect()
        }, batchUpdate: { updatedProperties, components in
          
            let componentIds = components.map(({ $0.id.uuidString }))
            let componentPredicate = NSPredicate(format: "id IN %@", componentIds)
            let componentMileageIds = components.map(({ $0.mileage.id.uuidString }))
            let searchPredicate = NSPredicate(format: "id IN %@", componentMileageIds)
            
            return Current.coreDataStack().batchUpdate(_MileageMO.self, updatedProperties, predicate: searchPredicate)
                .publisher
                .mapError({ _ in Failure() })
                .flatMap({ _ in Current.coreDataStack().fetch(_ComponentMO.self, predicate: componentPredicate).publisher })
                .map({ $0.map({ $0.asComponent() }) })
                .mapError { _ in Failure() }
                .eraseToEffect()
            
        }, delete: { model in
            guard let managedObject = try? Current.coreDataStack().fetchFirst(_ComponentMO.self, predicate: NSPredicate(format: "id == %@", model.id.uuidString)).get() else {
                return .none
            }
            
            return .fireAndForget {
                Current.coreDataStack().delete(managedObject)
            }
        }
    )
}

public extension ComponentClient {
    static var failing: Self = Self(
        create: { _,_ in
            .failing("\(Self.self).create is unimplemented")
        }, update: { _ in
            .failing("\(Self.self).update is unimplemented")
        }, batchUpdate: { _,_ in
            .failing("\(Self.self).update is unimplemented")
        }, delete: { _ in
            .failing("\(Self.self).delete is unimplemented")
        }
    )
    
    static var noop: Self = Self(
        create: { _,_ in
            .none
        }, update: { _ in
            .none
        }, batchUpdate: { _,_ in
            .none
        }, delete: { _ in
            .none
        }
    )
}

private var components: [Component] = [
    .shimanoSLXBrakes,
    .shimanoXLTBrakeRotor,
    .racefaceCogsette,
    .wtbFrontWheelSet,
    .yeti165Frame,
    .racefaceCarbon69Handlebars
]

public extension ComponentClient {
    static var mocked: Self = Self(
        create: { _, new in
            Effect(value: new)
                .eraseToEffect()
        }, update: { updated in
            Effect(value: updated)
                .eraseToEffect()
        }, batchUpdate: { properties, updated in
            
            var updatedComponent = updated.map { comp -> Component in
                var component = comp
                component.mileage.miles = 0
                return component
            }
            
            return Effect(value: updatedComponent)
                .eraseToEffect()
        }, delete: { _ in
            .none
        }
    )
}
