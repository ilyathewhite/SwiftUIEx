//
//  AnimatedBinding.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/11/21.
//

import SwiftUI

public extension Animation {
    func `repeat`(while value: Bool, autoreverses: Bool = true) -> Animation {
        value ? repeatForever(autoreverses: autoreverses) : self
    }
}

public func withAnimation<Result>(_ animation: Animation? = .default, while value: Bool, _ body: () throws -> Result) rethrows -> Result {
    guard let animation = animation else { return try body() }
    return try withAnimation(animation.repeat(while: value), body)
}

public struct Animated<ContentView: View, T: Equatable>: View {
    @Binding var binding: T
    @State private var value: T
    private var animation: (T) -> Animation
    private var content: (T) -> ContentView

    public init(_ binding: Binding<T>, with animation: @escaping (T) -> Animation, @ViewBuilder content: @escaping (T) -> ContentView) {
        self._binding = binding
        self._value = State(initialValue: binding.wrappedValue)
        self.animation = animation
        self.content = content
    }

    public var body: some View {
        VStack { // use VStack to work around a bug in iOS 14
            content(value)
        }
        .onChange(of: binding) { value in
            withAnimation(animation(value)) {
                self.value = value
            }
        }
    }
}

#if DEBUG
private struct AnimatedBindingPreview: View {
    @State private var expanded = false

    var body: some View {
        VStack(spacing: 24) {
            Toggle("Expand", isOn: $expanded)
            Animated($expanded, with: { _ in .easeInOut(duration: 0.5) }, content: { value in
                RoundedRectangle(cornerRadius: 16)
                    .fill(.blue)
                    .frame(width: value ? 240 : 100, height: value ? 120 : 60)
            })
            .frame(width: 260, height: 140)
        }
        .padding()
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Animated Binding", traits: .sizeThatFitsLayout) {
    AnimatedBindingPreview()
}
#endif
