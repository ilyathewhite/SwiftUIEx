//
//  Focus.swift
//
//  Created by Ilya Belenkiy on 1/15/24.
//

import SwiftUI

#if os(macOS)

public extension View {
    func focusableHidingRing() -> some View {
        self.focusable().focusEffectDisabled()
    }
}

#endif

#if DEBUG && os(macOS)
private struct FocusPreview: View {
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text(focused ? "Focused" : "Not focused")
                .padding()
                .frame(width: 180)
                .background(.blue.opacity(focused ? 0.25 : 0.1), in: RoundedRectangle(cornerRadius: 12))
                .focusableHidingRing()
                .focused($focused)
            Button("Move focus to the card") { focused = true }
        }
        .padding()
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Focus", traits: .sizeThatFitsLayout) {
    FocusPreview()
}
#endif
