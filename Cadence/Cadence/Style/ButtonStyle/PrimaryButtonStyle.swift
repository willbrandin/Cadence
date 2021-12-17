import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(.title3, design: .default).bold())
            .foregroundColor(colorScheme == .dark ? .black : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color(colorScheme == .dark ? .white : .black))
            .clipShape(RoundedRectangle(cornerRadius: 48, style: .continuous))
            .opacity(configuration.isPressed ? 0.4 : 1)
            .padding(.horizontal, 16)
            .padding(.bottom)
    }
}

@available(iOS 13.0.0, *)
struct PrimaryButtonStylePreviews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                Button("Add Service", action: {})
                    .buttonStyle(PrimaryButtonStyle())

            }
            VStack {
                Button("Add Service", action: {})
                    .buttonStyle(PrimaryButtonStyle())
                
            }
            .preferredColorScheme(.dark)
        }
    }
}
