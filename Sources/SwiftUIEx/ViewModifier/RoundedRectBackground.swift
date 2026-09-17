//
//  RoundedRectBackground.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/6/21.
//

import SwiftUI

public struct RoundedRectBackground: ViewModifier {
    struct BackgroundShape: Shape {
        var cornerRadius: CornerRadius

        var animatableData: CGFloat {
            get {
                switch cornerRadius {
                case .value(let radius): return radius
                case .max: return 0
                }
            }
            set {
                switch cornerRadius {
                case .value: cornerRadius = .value(newValue)
                case .max: break
                }
            }
        }

        func path(in rect: CGRect) -> Path {
            let radius: CGFloat
            switch cornerRadius {
            case .value(let value):
                radius = value
            case .max:
                radius = rect.height / 2
            }
            return RoundedRectangle(cornerRadius: radius).path(in: rect)
        }
    }

    public enum CornerRadius: Sendable {
        case value(CGFloat)
        case max
    }

    let fillColor: Color
    let borderColor: Color
    let cornerRadius: CornerRadius
    let borderWidth: CGFloat

    public func body(content: Content) -> some View {
        let shape = BackgroundShape(cornerRadius: cornerRadius)
        content
            .background(shape.fill(fillColor))
            .overlay(shape.stroke(borderColor, lineWidth: borderWidth))
            .clipShape(shape)
    }
}

public extension View {
    func roundedRectBackground(
        fillColor: Color = .clear,
        borderColor: Color = .clear,
        cornerRadius: RoundedRectBackground.CornerRadius = .max,
        borderWidth: CGFloat = 0
    )
    -> some View
    {
        let view = RoundedRectBackground(
            fillColor: fillColor,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            borderWidth: borderWidth
        )
        return modifier(view)
    }
}

#if DEBUG
private struct RoundedRectBackgroundPreview: View {
    @State private var radius: Double = 12

    var body: some View {
        VStack(spacing: 20) {
            Text("Fixed radius")
                .padding(24)
                .roundedRectBackground(
                    fillColor: .blue.opacity(0.15),
                    borderColor: .blue,
                    cornerRadius: .value(radius),
                    borderWidth: 2
                )
            Slider(value: $radius, in: 0...40)
            Text("Maximum radius")
                .padding()
                .roundedRectBackground(fillColor: .green.opacity(0.15), borderColor: .green, borderWidth: 2)
            Text("Tall")
                .frame(width: 60, height: 100)
                .roundedRectBackground(fillColor: .orange.opacity(0.2))
        }
        .padding()
        .frame(width: 300)
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Light", traits: .sizeThatFitsLayout) {
    RoundedRectBackgroundPreview()
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Dark", traits: .sizeThatFitsLayout) {
    RoundedRectBackgroundPreview().preferredColorScheme(.dark)
}
#endif
