//
//  SilhouetteInverseFill.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/6/21.
//

import SwiftUI

public struct SilhouetteInverseFill: ViewModifier {
    public let color: Color

    public func body(content: Content) -> some View {
        let mask = content
            .compositingGroup()
            .luminanceToAlpha()

        return content
            .overlay(color)
            .mask(mask)
            .compositingGroup() // necessary if the caller changes opacity
    }
}

public extension View {
    func silhouetteInverseFill(color: Color) -> some View {
        modifier(SilhouetteInverseFill(color: color))
    }
}

#if DEBUG
private struct SilhouetteInverseFillPreview: View {
    var body: some View {
        HStack(spacing: 32) {
            Image(systemName: "leaf.fill").foregroundStyle(.white)
            Image(systemName: "leaf.fill").foregroundStyle(.white).silhouetteInverseFill(color: .green)
            Image(systemName: "leaf.fill").foregroundStyle(.white)
                .silhouetteInverseFill(color: .blue).opacity(0.5)
        }
        .font(.system(size: 60))
        .padding(32)
        .background(.gray.opacity(0.3))
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Silhouette Inverse Fill", traits: .sizeThatFitsLayout) {
    SilhouetteInverseFillPreview()
}
#endif
