import SwiftUI
import CustomDump

struct StoreJsonView: View {
    private let viewStore = globalViewStore
    
    private var jsonText: String {
        return "\(String(describing: viewStore?.state))"
    }
    
    var body: some View {
        ScrollView {
            Text(jsonText)
        }
        .interactiveDismissDisabled()
        .navigationBarTitleDisplayMode(.inline)
        .padding(.bottom)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    let pasteBoard = UIPasteboard.general
                    pasteBoard.string = jsonText
                }) {
                    Image(systemName: "doc.on.doc")
                }
            }
        }
    }
}

struct StoreJsonView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StoreJsonView()
        }
    }
}
