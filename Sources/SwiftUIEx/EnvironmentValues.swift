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

private struct IsHiddenKey: EnvironmentKey {
    static let defaultValue = false
}

public extension EnvironmentValues {
    var isHidden: Bool {
        get { self[IsHiddenKey.self] }
        set { self[IsHiddenKey.self] = newValue }
    }
}

private struct WindowTitleKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

public extension EnvironmentValues {
    var windowTitle: String? {
        get { self[WindowTitleKey.self] }
        set { self[WindowTitleKey.self] = newValue }
    }
}

private struct ExitActionKey: EnvironmentKey {
    static let defaultValue: (() -> ())? = nil
}

public extension EnvironmentValues {
    var exitAction: (() -> ())? {
        get { self[ExitActionKey.self] }
        set { self[ExitActionKey.self] = newValue }
    }
}
