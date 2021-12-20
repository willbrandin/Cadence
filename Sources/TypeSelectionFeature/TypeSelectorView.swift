import SwiftUI

protocol TypeViewSelectable: Identifiable, Equatable {
    var title: String { get }
}

struct TypeSelectorView<T: TypeViewSelectable>: View {
    
    var title: String
    var items: [T]
    @Binding var selected: T?
    
    public var body: some View {
        List(items) { item in
            Button(action: { selected = item }) {
                HStack {
                    Text(item.title)
                        .padding(.vertical)
                    Spacer()
                    if item == selected {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
