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
        Button(action: action) {
            HStack {
                label
                Spacer()
                Image(systemName:"chevron.right")
                    .foregroundColor(.systemGray3)
                    .font(.body.weight(.semibold))
                    .padding(.leading)
            }
            .contentShape(Rectangle())
            .foregroundColor(.label)
        }
    }
}
