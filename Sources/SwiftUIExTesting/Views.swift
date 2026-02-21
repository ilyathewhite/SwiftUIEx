//
//  Views.swift
//  SwiftUIEx
//
//  Created by Ilya Belenkiy on 2/16/26.
//

import UIKit

@MainActor
public func firstView(where predicate: (UIView) -> Bool) -> UIView? {
    let windows = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .flatMap { $0.windows }

    var queue: [UIView] = windows

    while !queue.isEmpty {
        let current = queue.removeFirst()
        if predicate(current) {
            return current
        }
        queue.append(contentsOf: current.subviews)
    }

    return nil
}

@MainActor
public func viewWithAccessibilityLabel(_ label: String) throws -> UIView {
    if let view = firstView(where: { $0.accessibilityLabel == label }) {
        return view
    }
    else {
        throw TestKit.TestingError.missingViewWithAccessibilityLabel(label)
    }
}

@MainActor
public func firstSceneWindow() throws -> UIWindow {
    guard let windowScene = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .first,
        let window = windowScene.windows.first
    else {
        throw TestKit.TestingError.missingFirstSceneWindow
    }

    return window
}
