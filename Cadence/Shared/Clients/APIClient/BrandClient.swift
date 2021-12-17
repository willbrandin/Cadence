//import Foundation
//import ComposableArchitecture
//import Models
//
//struct BrandClient {
//    var requestBrands: () -> Effect<[Brand], Never>
//    
//    init(
//        requestBrands: @escaping () -> Effect<[Brand], Never>
//    ) {
//        self.requestBrands = requestBrands
//    }
//}
//
//extension BrandClient {
//    static var live: Self = Self(
//        requestBrands: {
//            guard let brandsListPath = Bundle.main.path(forResource: "BikeBrandData", ofType: "json") else { return .none }
//            
//            do {
//                let brandData = try Data(contentsOf: URL(fileURLWithPath: brandsListPath), options: .mappedIfSafe)
//                let brands = try JSONDecoder().decode([Brand].self, from: brandData)
//                
//                return Effect(value: brands)
//                    .eraseToEffect()
//            } catch {
//                print(error)
//                return .none
//            }
//            
//        }
//    )
//}
//
//#if DEBUG
//extension BrandClient {
//    public static let mocked = BrandClient(
//        requestBrands: {
//            return Effect(value: .brandList)
//                .eraseToEffect()
//        }
//    )
//    
//    public static let alwaysFailing = BrandClient(
//        requestBrands: { .failing("BrandClient.requestBrands") }
//    )
//}
//
//private let queue = DispatchQueue(label: "BrandClient")
//#endif
