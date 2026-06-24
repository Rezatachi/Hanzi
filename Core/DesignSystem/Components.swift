import SwiftUI

public struct ToneBadge: View {
    private let text: String
    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.driftBackgroundSecondary)
            .clipShape(Capsule())
    }
}
