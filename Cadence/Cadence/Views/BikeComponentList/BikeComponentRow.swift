import SwiftUI
import BikeClient
import MileageClient
import ComposableArchitecture
import Models
import MileageScaleFeature

struct BikeComponentRow: View {
    let component: Component
    let distanceUnit: DistanceUnit
    
    var body: some View {
        VStack(spacing: 16) {
            VStack {
                HStack {
                    Text(component.cellTitle)
                        .bold()
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    HStack(spacing: 2) {
                        Text(component.brand.brand)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        if let model = component.model {
                            Text(model)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    
                    Spacer()
                }
                
            }
            HStack {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(component.mileage.miles)")
                        .font(.title2)
                        .fontWeight(.black)
                    Text(distanceUnit.title)
                        .font(.callout)
                        .bold()
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack {
                    MileageScaleView(mileage: component.mileage)
                }
            }
        }
        .foregroundColor(.primary)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}


struct BikeComponentRow_Previews: PreviewProvider {
    static var previews: some View {
        BikeComponentRow(component: .shimanoSLXBrakes, distanceUnit: .miles)
    }
}
