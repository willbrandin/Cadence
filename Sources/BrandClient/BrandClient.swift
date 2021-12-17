import Foundation
import ComposableArchitecture
import Models

public struct BrandClient {
    public var requestBrands: () -> Effect<[Brand], Never>
    
    public init(
        requestBrands: @escaping () -> Effect<[Brand], Never>
    ) {
        self.requestBrands = requestBrands
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
            
        }
    )
}

#if DEBUG
extension BrandClient {
    public static let mocked = BrandClient(
        requestBrands: {
            return Effect(value: .brandList)
                .eraseToEffect()
        }
    )
    
    public static let alwaysFailing = BrandClient(
        requestBrands: { .failing("BrandClient.requestBrands") }
    )
}

private let queue = DispatchQueue(label: "BrandClient")
#endif
