import ComposableArchitecture
import Combine
import Models

struct MileageClient {
    struct Failure: Error, Equatable {}
    
    var create: (Mileage) -> Effect<Mileage, MileageClient.Failure>
    var update: (Mileage) -> Effect<Mileage, MileageClient.Failure>
    var updateFromUnit: (DistanceUnit) -> Effect<Mileage, MileageClient.Failure>
}

extension MileageClient {
    static var live: Self = Self(
        create: { mileage in
            let mileageMO = MileageMO.initFrom(mileage)
            return Current.coreDataStack().create(mileageMO)
                .publisher
                .map({$0.asMileage()})
                .mapError { _ in Failure() }
                .eraseToEffect()
        }, update: { mileage in
            guard let mileageMO = try? Current.coreDataStack().fetchFirst(MileageMO.self, predicate: NSPredicate(format: "id == %@", mileage.id.uuidString)).get() else {
                return Effect(error: .init())
            }
            
            return Current.coreDataStack().update(mileageMO)
                .publisher
                .map({ $0.asMileage() })
                .mapError { _ in Failure() }
                .eraseToEffect()
        }, updateFromUnit: { unit in
            guard let mileages = try? Current.coreDataStack().fetch(MileageMO.self, predicate: nil, limit: nil).get()
            else { return Effect(error: .init()) }
            
            var effects = mileages.map { mileage -> Effect<Mileage, MileageClient.Failure> in
                let updated = DistanceUnit.convert(to: unit, value: Double(mileage.miles))
                mileage.miles = Int16(updated)
                return Current.coreDataStack().update(mileage)
                    .publisher
                    .map { $0.asMileage() }
                    .mapError { _ in Failure() }
                    .eraseToEffect()
            }
            
            return .merge(effects)
        }
    )
}

extension MileageClient {
    static var failing: Self = Self(
        create: { _ in
            .failing("\(Self.self).create is unimplemented")
        },
        update: { _ in
            .failing("\(Self.self).update is unimplemented")
        }, updateFromUnit: { _ in
                .failing("\(Self.self).updateFrom is unimplemented")
        }
    )
    
    static var noop: Self = Self(
        create: { _ in
            .none
        },
        update: { _ in
            .none
        }, updateFromUnit: { _ in
            .none
        }
    )
}

extension MileageClient {
    static var mocked: Self = Self(
        create: { new in
            Effect(value: new)
                .eraseToEffect()
        },
        update: { updated in
            Effect(value: updated)
                .eraseToEffect()
        }, updateFromUnit: { _ in
            .none
        }
    )
}
