import SwiftUI

struct DistanceUnitPickerView: View {
    @Binding var distanceUnit: DistanceUnit
    
    var body: some View {
        Form {
            Section(
                footer: Text("This will convert your current distance on your bikes, components, and rides to match your preferred unit.")
            ) {
                ForEach(DistanceUnit.allCases, id: \.self) { unit in
                    HStack {
                        Button(action: { distanceUnit = unit }) {
                            HStack {
                                Text(unit.title.capitalized)
                                Spacer()
                                
                                Image(systemName: distanceUnit == unit ? "checkmark.circle.fill" : "circle")
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("Distance Unit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DistanceUnitPickerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DistanceUnitPickerView(distanceUnit: .constant(.miles))
        }
    }
}

