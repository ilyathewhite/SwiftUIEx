//
//  MasterDetailView.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/20/21.
//

import SwiftUI

public protocol DetailView: View {
    var showBackButton: Bool { get set }
    var backAction: () -> Void { get set }
}

public struct DetailContainerView<Content: View>: DetailView {
    public var showBackButton: Bool = false
    public var backAction: () -> Void = {}
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
            content
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        if showBackButton {
                            Button(action: { withAnimation { backAction() } }) {
                                Image(systemName: "chevron.backward")
                            }
                        }
                    }
                }
    }
}

public extension Animation {
    static let slide: Self = spring(response: 0.3, dampingFraction: 1)
}

public struct MasterDetailView<Master: View, Detail: DetailView>: View {
    let master: Master
    var detail: Detail
    let masterWidth: CGFloat
    let showAll: Bool
    
    @Binding var showDetail: Bool
    
    public init(master: () -> Master, detail: () -> Detail, masterWidth: CGFloat = 375, showAll: Bool, showDetail: Binding<Bool>) {
        self.master = master()
        self.detail = detail()
        self.detail.showBackButton = !showAll
        self.detail.backAction = { showDetail.wrappedValue = false }
        self.masterWidth = masterWidth
        self.showAll = showAll
        self._showDetail = showDetail
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                master
                    .frame(width: showAll ? masterWidth : nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .zIndex(0)
                
                if showAll {
                    HStack {
                        Spacer()
                            .frame(width: masterWidth)
                        Divider()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .zIndex(2)
                }
                
                if showDetail || showAll {
                    let detailIdealWidth = proxy.size.width - masterWidth
                    let detailWidth = (showAll && (detailIdealWidth > 0)) ? detailIdealWidth : nil
                    detail
                        .frame(width: detailWidth)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .zIndex(1)
                        .transition(showAll ? .identity : .move(edge: .trailing))
                }
            }
        }
    }
}

#if DEBUG
private struct MasterDetailViewPreview: View {
    let showAll: Bool
    @State private var showDetail = false
    @State private var selection = "First"

    var body: some View {
        MasterDetailView(
            master: {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Items").font(.headline)
                    ForEach(["First", "Second", "Third"], id: \.self) { item in
                        Button(item) {
                            selection = item
                            withAnimation(.slide) { showDetail = true }
                        }
                    }
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.systemBackground)
            },
            detail: {
                DetailContainerView {
                    VStack(spacing: 16) {
                        Text("\(selection) item").font(.title)
                        if !showAll {
                            Button("Back") { withAnimation(.slide) { showDetail = false } }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.systemBackground)
                }
            },
            masterWidth: 180,
            showAll: showAll,
            showDetail: $showDetail
        )
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Side by side", traits: .fixedLayout(width: 600, height: 320)) {
    NavigationStack { MasterDetailViewPreview(showAll: true) }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Compact navigation", traits: .fixedLayout(width: 320, height: 400)) {
    NavigationStack { MasterDetailViewPreview(showAll: false) }
}
#endif
