import SwiftUI
import Models


public struct MileageScaleView: View {
    public init(mileage: Mileage, width: CGFloat = 96) {
        self.mileage = mileage
        self.width = width
    }
    
    public var mileage: Mileage
    public var width: CGFloat = 96
    
    var value: Float {
        let miles = Float(mileage.miles)
        let recommended = Float(mileage.recommendedMiles)
        let percent = miles / recommended
        return min(percent, 1)
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            Text(mileage.mileageStatusTypeId.title)
                .font(.callout)
                .bold()
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .padding(.bottom, 2)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 33, style: .continuous)
                    .frame(width: width, height: 8)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.lightGray))

                RoundedRectangle(cornerRadius: 33, style: .continuous)
                    .frame(width: min(CGFloat(self.value) * width, width), height: 8)
                    .foregroundColor(mileage.mileageStatusTypeId.statusColor)
            }
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
        }
        .frame(width: width)
    }
}

struct MileageScaleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            MileageScaleView(mileage: .low)
            MileageScaleView(mileage: .good)
            MileageScaleView(mileage: .okay)
            MileageScaleView(mileage: .upper)
            MileageScaleView(mileage: .high)
        }
    }
}
