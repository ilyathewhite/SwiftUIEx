//
//  WrappingHStack.swift
//
//
//  Created by Ilya Belenkiy on 8/27/21.
//

import SwiftUI

@available(tvOS 16.0, *)
struct WrappingLayout: Layout {
    let rowAlignment: VerticalAlignment
    let spacing: CGFloat
    let rowSpacing: CGFloat

    struct Arrangement {
        let frames: [CGRect]
        let size: CGSize
    }

    func arrangement(sizes: [CGSize], width: CGFloat?) -> Arrangement {
        let limit = width.flatMap { $0.isFinite ? max(0, $0) : nil }
        var frames: [CGRect] = []
        var rowStart = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var contentWidth: CGFloat = 0
        var y: CGFloat = 0

        func finishRow() {
            guard rowStart < frames.count else { return }
            for index in rowStart..<frames.count {
                let offset: CGFloat
                switch rowAlignment {
                case .top: offset = 0
                case .bottom: offset = rowHeight - frames[index].height
                default: offset = (rowHeight - frames[index].height) / 2
                }
                frames[index].origin.y = y + offset
            }
            contentWidth = max(contentWidth, rowWidth)
            y += rowHeight
            rowStart = frames.count
            rowWidth = 0
            rowHeight = 0
        }

        for size in sizes {
            if let limit, rowStart < frames.count, rowWidth + spacing + size.width > limit {
                finishRow()
                y += rowSpacing
            }
            let x = rowStart == frames.count ? 0 : rowWidth + spacing
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowWidth = x + size.width
            rowHeight = max(rowHeight, size.height)
        }
        finishRow()

        return Arrangement(frames: frames, size: CGSize(width: max(limit ?? 0, contentWidth), height: y))
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrangement(sizes: subviews.map { $0.sizeThatFits(.unspecified) }, width: proposal.width).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangement(sizes: subviews.map { $0.sizeThatFits(.unspecified) }, width: proposal.width)
        for (subview, frame) in zip(subviews, result.frames) {
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(frame.size)
            )
        }
    }
}

@available(tvOS 16.0, *)
public struct WrappingHStack<Data, Cell>: View where Data: RandomAccessCollection, Data.Element: Identifiable, Cell: View {
    let rowAlignment: VerticalAlignment
    let spacing: CGFloat
    let rowSpacing: CGFloat
    let data: [Data.Element]
    let cellFunc: (Data.Element) -> Cell

    public init(
        rowAlignment: VerticalAlignment = .center,
        spacing: CGFloat = 10,
        rowSpacing: CGFloat? = nil,
        _ dataContent: Data,
        content: @escaping (Data.Element) -> Cell
    ) {
        self.rowAlignment = rowAlignment
        self.spacing = spacing
        self.rowSpacing = rowSpacing ?? spacing

        var data: [Data.Element] = []
        for elem in dataContent {
            // inefficient, but most flexible and should not be a problem for a small collection
            // that WrappingHStack is meant to display.
            if !data.contains(where: {$0.id == elem.id }) {
                data.append(elem)
            }
            else {
                SwiftUIEx.env.logCodingError("WrappingHStack expected elements with unique IDs. Found duplicate ID: \(elem.id)")
            }
        }
        self.data = data

        self.cellFunc = content
    }

    public var body: some View {
        WrappingLayout(rowAlignment: rowAlignment, spacing: spacing, rowSpacing: rowSpacing) {
            ForEach(data) { element in
                cellFunc(element).fixedSize()
            }
        }
    }
}

#if DEBUG
@available(tvOS 16.0, *)
private struct WrappingHStackPreview: View {
    struct Tag: Identifiable {
        let text: String
        var id: UUID

        init(_ text: String) {
            self.text = text
            id = UUID()
        }
    }

    static let strings = [
        "#viral",  "#share", "#youtubekids", "#subscribers", "#trending",
        "#comment", "#followforfollowback", "youtubemusic", "#contentcreator", "#explore",
        "#music", "#follow"
    ]

    @State var data: [Tag] = WrappingHStackPreview.strings.prefix(8).map(Tag.init)

    func removeFirst() {
        _ = withAnimation(.easeInOut(duration: 0.5)) {
            data.removeFirst()
        }
    }

    func removeLast() {
        _ = withAnimation(.easeInOut(duration: 0.5)) {
            data.removeLast()
        }
    }

    func addRandom() {
        withAnimation(.easeInOut(duration: 0.5)) {
            data.append(.init(Self.strings.randomElement() ?? ""))
        }
    }

    var body: some View {
        VStack {
            WrappingHStack(data) { tag in
                Text(tag.text)
                    .padding(7)
                    .roundedRectBackground(borderColor: .gray, cornerRadius: .value(7), borderWidth: 2)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
            }
            .padding()

            HStack(spacing: 30) {
                Button("Add", action: addRandom)
                Button("- First", action: removeFirst)
                Button("- Last", action: removeLast)
            }

            Spacer()
        }
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Wrapping stack", traits: .fixedLayout(width: 360, height: 320)) {
    WrappingHStackPreview()
}
#endif
