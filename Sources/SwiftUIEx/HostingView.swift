//
//  HostingView.swift
//
//  Created by Ilya Belenkiy on 3/3/24.
//

#if os(iOS)

import UIKit
import SwiftUI

public class HostingView<Content>: UIView where Content: View {
    let vc: UIHostingController<Content>
    
    public init(rootView: Content) {
        vc = .init(rootView: rootView)
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window else { return }
        guard let rootVC = window.rootViewController else { return }
        guard let view = vc.view else { return }
        view.backgroundColor = .clear

        rootVC.addChild(vc)
        addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        vc.didMove(toParent: rootVC)
    }
}
    
#endif
