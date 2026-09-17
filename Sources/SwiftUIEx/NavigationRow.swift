//
//  File.swift
//  
//
//  Created by Ilya Belenkiy on 4/2/23.
//

import SwiftUI

public struct NavigationRow<V: View>: View {
    public let label: V
    public let action: () -> Void

    public init(action: @escaping () -> Void, label: @autoclosure () -> V) {
        self.label = label()
        self.action = action
    }

    public init(action: @escaping () -> Void, label: () -> V) {
        self.label = label()
        self.action = action
    }

    public init(_ titleKey: LocalizedStringKey, action: @escaping () -> Void) where V == Text {
        self.init(action: action, label: Text(titleKey))
    }

    public init(_ title: String, action: @escaping () -> Void) where V == Text {
        self.init(action: action, label: Text(title))
    }

    public var body: some View {
        HStack {
            label
            Spacer()
            Image(systemName:"chevron.right")
                .foregroundColor(.quaternaryLabel)
                .font(.footnote.weight(.bold))
                .padding(.leading)
        }
        .frame(maxHeight: .infinity)
        .contentShape(Rectangle())
        .foregroundColor(.primary)
        .onTapGesture(perform: action)
    }
}

#if DEBUG
private struct NavigationRowPreview: View {
    @State private var selection = "None"

    var body: some View {
        VStack(spacing: 0) {
            NavigationRow("Settings", action: { selection = "Settings" })
                .frame(height: 48)
            Divider()
            NavigationRow(action: { selection = "Favorites" }, label: {
                Label("Favorites", systemImage: "star")
            })
            .frame(height: 48)
            Divider()
            Text("Selected: \(selection)").font(.caption).padding(.top)
        }
        .padding()
        .frame(width: 300)
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Navigation Row", traits: .sizeThatFitsLayout) {
    NavigationRowPreview()
}
#endif
