//
//  ShowIf.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 9/1/21.
//

import SwiftUI

public struct ShowIf: ViewModifier {
    public let value: Bool
    public let animation: Animation?

    public func body(content: Content) -> some View {
        if value {
            content.transition(.opacity.animation(animation))
        }
    }
}

public extension View {
    func showIf(_ value: Bool, animation: Animation? = nil) -> some View {
        modifier(ShowIf(value: value, animation: animation))
    }
}

#if DEBUG
private struct ShowIfPreview: View {
    @State private var visible = true

    var body: some View {
        VStack(spacing: 20) {
            Toggle("Show content", isOn: $visible)
            Label("Visible content", systemImage: "eye")
                .padding()
                .background(.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                .showIf(visible, animation: .easeInOut(duration: 0.3))
        }
        .padding()
        .frame(width: 280, height: 160, alignment: .top)
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Show If", traits: .sizeThatFitsLayout) {
    ShowIfPreview()
}
#endif
