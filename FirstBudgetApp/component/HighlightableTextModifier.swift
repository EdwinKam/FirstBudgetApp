import SwiftUI

struct HighlightableTextModifier: ViewModifier {
    var isEnable: Bool

    func body(content: Content) -> some View {
        content
            .font(.body)
            .padding(5)
            .background(isEnable ? Color.yellow.opacity(0.3) : Color.clear)
            .cornerRadius(5)
            .foregroundColor(Color(.label)) // Adapts to dark mode
    }
}

extension View {
    func highlight(isEnable: Bool) -> some View {
        self.modifier(HighlightableTextModifier(isEnable: isEnable))
    }
}
