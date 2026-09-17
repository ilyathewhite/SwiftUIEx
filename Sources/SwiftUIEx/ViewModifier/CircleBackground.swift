//
//  CircleBackground.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/6/21.
//

import SwiftUI

@available(tvOS 16.0, *)
struct SquareLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let content = subviews.first else { return .zero }
        let size = content.sizeThatFits(proposal)
        let side = max(size.width, size.height)
        return CGSize(width: side, height: side)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.first?.place(
            at: CGPoint(x: bounds.midX, y: bounds.midY),
            anchor: .center,
            proposal: ProposedViewSize(bounds.size)
        )
    }
}

@available(tvOS 16.0, *)
public struct CircleBackground: ViewModifier {
    public let fillColor: Color
    public let borderColor: Color
    public let borderWidth: CGFloat

    public func body(content: Content) -> some View {
        let shape = Circle()
        SquareLayout { content }
            .background(shape.fill(fillColor))
            .overlay(shape.stroke(borderColor, lineWidth: borderWidth))
            .clipShape(shape)
    }
}

public extension View {
    @available(tvOS 16.0, *)
    func circleBackground(fillColor: Color = .clear, borderColor: Color = .clear, borderWidth: CGFloat = 0) -> some View {
        modifier(CircleBackground(fillColor: fillColor, borderColor: borderColor, borderWidth: borderWidth))
    }
}

#if DEBUG
@available(tvOS 16.0, *)
private struct CircleBackgroundPreview: View {
    var body: some View {
        HStack(spacing: 24) {
            Image(systemName: "music.note")
                .font(.largeTitle)
                .padding()
                .circleBackground(fillColor: .blue.opacity(0.15), borderColor: .blue, borderWidth: 2)
            Text("Wide label")
                .padding()
                .circleBackground(fillColor: .orange.opacity(0.2), borderColor: .orange, borderWidth: 4)
            Text("Tall")
                .frame(width: 40, height: 100)
                .circleBackground(fillColor: .green.opacity(0.15))
        }
        .padding()
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Circle Background", traits: .sizeThatFitsLayout) {
    CircleBackgroundPreview()
}
#endif
