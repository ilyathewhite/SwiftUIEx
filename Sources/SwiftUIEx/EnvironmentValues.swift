//
//  EnvironmentValues.swift
//
//  Created by Ilya Belenkiy on 8/13/23.
//

import SwiftUI

private struct ForegroundColorKey: EnvironmentKey {
    static let defaultValue: Color = .primary
}

public extension EnvironmentValues {
    /// foregroundColor for UIKit components
    var foregroundColor: Color {
        get { self[ForegroundColorKey.self] }
        set { self[ForegroundColorKey.self] = newValue }
    }
}
