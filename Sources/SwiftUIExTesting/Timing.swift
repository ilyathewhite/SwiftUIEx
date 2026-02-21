//
//  Timing.swift
//  SwiftUIEx
//
//  Created by Ilya Belenkiy on 2/16/26.
//

@MainActor
public func finishAnimation(
    _ type: TestKit.AnimationType,
    _ description: String
) async {
    try? await Task.sleep(for: type.duration)
}
