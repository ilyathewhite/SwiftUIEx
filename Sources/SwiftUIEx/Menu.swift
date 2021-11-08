//
//  Menu.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 11/8/21.
//

import SwiftUI

public func menuItem(destructive: Bool = false, text: String, iconName: String, action: @escaping () -> Void) -> some View {
    if #available(iOS 15, *) {
        return Button(
            role: destructive ? .destructive : nil,
            action: action,
            label: {
                HStack {
                    Text(text)
                    Image(systemName: iconName)
                }
            }
        )
    }
    else {
        return Button(action: action) {
            HStack {
                Text(text)
                Image(systemName: iconName)
            }
        }
    }
}
