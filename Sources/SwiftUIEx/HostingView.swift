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
        guard window != nil else { return }
        guard let view = vc.view else { return }
        view.backgroundColor = .clear
        addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
    
#endif

#if DEBUG && os(iOS)
private struct HostingViewPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        HostingView(rootView:
            VStack(spacing: 12) {
                Image(systemName: "square.stack.3d.up").font(.largeTitle)
                Text("SwiftUI content inside a UIKit hosting view")
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.blue.opacity(0.15))
        )
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Hosting view", traits: .fixedLayout(width: 300, height: 160)) {
    HostingViewPreview()
}
#endif
