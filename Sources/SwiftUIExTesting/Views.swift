//
//  Views.swift
//  SwiftUIEx
//
//  Created by Ilya Belenkiy on 2/16/26.
//

import Foundation

#if canImport(UIKit)
import UIKit

typealias TestPlatformView = UIView
typealias TestPlatformWindow = UIWindow

private func accessibilityIdentifier(for view: TestPlatformView) -> String? {
    view.accessibilityIdentifier
}

@MainActor
func firstSceneWindow() -> UIWindow? {
    guard let windowScene = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .first,
        let window = windowScene.windows.first
    else {
        return nil
    }

    return window
}

@MainActor
public func firstView(where predicate: (UIView) -> Bool) -> UIView? {
    let windows = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap(\.windows)

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
    try firstViewWithAccessibilityLabel(label)
}

@MainActor
func firstViewWithAccessibilityLabel(_ label: String) throws -> UIView {
    guard let view = firstView(where: { $0.accessibilityLabel == label }) else {
        throw TestKit.TestingError.missingViewWithAccessibilityLabel(label)
    }
    return view
}

@MainActor
func viewWithAccessibilityLabel(_ label: String, in rootView: UIView) throws -> UIView {
    guard let view = firstView(in: rootView, where: { $0.accessibilityLabel == label }) else {
        throw TestKit.TestingError.missingViewWithAccessibilityLabel(label)
    }
    return view
}

#elseif canImport(AppKit)
import AppKit

typealias TestPlatformView = NSView
typealias TestPlatformWindow = NSWindow

private func accessibilityIdentifier(for view: TestPlatformView) -> String? {
    view.accessibilityIdentifier()
}
#endif

@MainActor
func firstView(
    in rootView: TestPlatformView,
    where predicate: (TestPlatformView) -> Bool
) -> TestPlatformView? {
    var queue: [TestPlatformView] = [rootView]

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
func viewWithAccessibilityIdentifier(
    _ identifier: String,
    in rootView: TestPlatformView
) throws -> TestPlatformView {
    guard let view = firstView(
        in: rootView,
        where: { accessibilityIdentifier(for: $0) == identifier }
    )
    else {
        throw TestKit.TestingError.missingViewWithAccessibilityIdentifier(identifier)
    }
    return view
}
