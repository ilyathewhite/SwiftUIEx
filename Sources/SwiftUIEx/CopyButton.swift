//
//  CopyButton.swift
//
//  Created by Ilya Belenkiy on 9/25/22.
//

import SwiftUI

public protocol TransferableEx: Transferable {
    associatedtype Preview: Transferable
#if os(macOS)
    @MainActor
    var pasteboardItem: NSPasteboardItem { get }
#else
    @MainActor
    var itemProvider: NSItemProvider { get }
#endif
    @MainActor
    var exportPreview: SharePreview<Never, Preview> { get }
}

#if !os(macOS)
extension TransferableEx {
    @MainActor
    public var itemProvider: NSItemProvider {
        let provider = NSItemProvider()
        provider.register(self)
        return provider
    }
}
#endif

public struct CopyButton<T: TransferableEx>: View {
    let value: T?
    
    @State private var didCopy = false
    
    var icon: String {
        didCopy ? "checkmark" : "square.on.square"
    }
    
    public init(_ value: T?) {
        self.value = value
    }
    
    func copy() {
        guard let value else { return }
#if os(macOS)
        let pboard = NSPasteboard.general
        pboard.clearContents()
        pboard.writeObjects([value.pasteboardItem])
#else
        let pboard = UIPasteboard.general
        pboard.setItemProviders([value.itemProvider], localOnly: false, expirationDate: nil)
#endif
        didCopy = true
        Task {
            try? await Task.sleep(for: .seconds(0.75))
            didCopy = false
        }
    }
    
    public var body: some View {
        Button(action: copy) {
            Image(systemName: icon)
                .padding()
                .contentShape(Rectangle())
        }
        .disabled(value == nil)
        .buttonStyle(.borderless)
    }
}
