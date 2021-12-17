import SwiftUI

struct ColorSchemePickerView: View {
    @Binding var colorScheme: ColorScheme
    
    var body: some View {
        Form {
            ForEach(ColorScheme.allCases, id: \.self) { scheme in
                HStack {
                    Button(action: { colorScheme = scheme }) {
                        HStack {
                            Text(scheme.title)
                            Spacer()
                            
                            Image(systemName: scheme == colorScheme ? "checkmark.circle.fill" : "circle")
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle("Theme")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ColorSchemePickerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ColorSchemePickerView(colorScheme: .constant(.system))
        }
    }
}
