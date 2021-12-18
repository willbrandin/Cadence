import SwiftUI

public struct SecondaryOutlineButtonStyle: ButtonStyle {
    
    public init() {}
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(.title3, design: .default).bold())
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.clear)
            .contentShape(RoundedRectangle(cornerRadius: 48, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: 48, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 48)
                    .stroke(Color.secondary, lineWidth: 0.5)
            )
            .opacity(configuration.isPressed ? 0.4 : 1)
            .padding(.horizontal, 16)
            .padding(.bottom)
    }
}

struct SecondaryOutlineButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button("Replace Component", action: {})
                .buttonStyle(SecondaryOutlineButtonStyle())
        }
    }
}
