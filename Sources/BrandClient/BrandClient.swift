import Foundation
import ComposableArchitecture
import CoreDataStack
import Models
import World

public struct BrandClient {
    public struct Failure: Error, Equatable {
        public init() {}
    }

    public var requestBrands: () -> Effect<[Brand], Never>
    public var createUserBrand: (Brand) -> Effect<Brand, BrandClient.Failure>
    public var requestUserBrands: () -> Effect<[Brand], BrandClient.Failure>
    
    public init(
        requestBrands: @escaping () -> Effect<[Brand], Never>,
        createUserBrand: @escaping (Brand) -> Effect<Brand, BrandClient.Failure>,
        requestUserBrands: @escaping () -> Effect<[Brand], BrandClient.Failure>
    ) {
        self.requestBrands = requestBrands
        self.createUserBrand = createUserBrand
        self.requestUserBrands = requestUserBrands
    }
}

public extension BrandClient {
    static var live: Self = Self(
        requestBrands: {
            guard let brandsListPath = Bundle.module.path(forResource: "BikeBrandData", ofType: "json") else { return .none }
            
            do {
                let brandData = try Data(contentsOf: URL(fileURLWithPath: brandsListPath), options: .mappedIfSafe)
                let brands = try JSONDecoder().decode([Brand].self, from: brandData)
                
                return Effect(value: brands)
                    .eraseToEffect()
            } catch {
                print(error)
                return .none
            }
        },
        createUserBrand: { brand in
            let managedObject = CustomBrandMO.initFrom(brand)
            return Current.coreDataStack().create(managedObject)
                .publisher
                .map({ $0.asBrand() })
                .mapError { _ in Failure() }
                .eraseToEffect()
        },
        requestUserBrands: {
            Current.coreDataStack().fetch(CustomBrandMO.self, predicate: nil)
                .publisher
                .map({ $0.map({ $0.asBrand() }) })
                .mapError { _ in Failure() }
                .eraseToEffect()
        }
    )
}

extension BrandClient {
    public static let mocked = BrandClient(
        requestBrands: {
            return Effect(value: .brandList)
                .eraseToEffect()
        },
        createUserBrand: { brand in
            return Effect(value: brand)
                .eraseToEffect()
        },
        requestUserBrands: {
            return Effect(value: [.shimano, .yeti])
                .eraseToEffect()
        }
    )
    
    public static let alwaysFailing = BrandClient(
        requestBrands: { .failing("BrandClient.requestBrands") },
        createUserBrand: { _ in .failing("BrandClient.createUserBrand")},
        requestUserBrands: { .failing("BrandClient.requestUserBrands") }
    )
}

private let queue = DispatchQueue(label: "BrandClient")
