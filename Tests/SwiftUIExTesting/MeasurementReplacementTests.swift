import SwiftUI
import Testing
@testable import SwiftUIEx

@MainActor
struct MeasurementReplacementTests {
    private let sizes = [CGSize(width: 40, height: 20), CGSize(width: 30, height: 40), CGSize(width: 50, height: 10)]

    @Test
    func wrappingFitsExactWidthsWithoutLeadingOrTrailingSpacing() {
        let layout = WrappingLayout(rowAlignment: .top, spacing: 10, rowSpacing: 7)
        let result = layout.arrangement(sizes: sizes, width: 80)
        #expect(result.frames == [
            CGRect(x: 0, y: 0, width: 40, height: 20),
            CGRect(x: 50, y: 0, width: 30, height: 40),
            CGRect(x: 0, y: 47, width: 50, height: 10)
        ])
        #expect(result.size == CGSize(width: 80, height: 57))
    }

    @Test(arguments: [VerticalAlignment.top, .center, .bottom])
    func wrappingAlignsDifferentCellHeights(alignment: VerticalAlignment) {
        let layout = WrappingLayout(rowAlignment: alignment, spacing: 10, rowSpacing: 7)
        let result = layout.arrangement(sizes: sizes, width: 140)
        let expectedY: [CGFloat]
        switch alignment {
        case .top: expectedY = [0, 0, 0]
        case .bottom: expectedY = [20, 0, 30]
        default: expectedY = [10, 0, 15]
        }
        #expect(result.frames.map(\.minY) == expectedY)
        #expect(result.frames.map(\.minX) == [0, 50, 90])
        #expect(result.size == CGSize(width: 140, height: 40))
    }

    @Test
    func wrappingRespondsToWidthAndContentChanges() {
        let layout = WrappingLayout(rowAlignment: .top, spacing: 10, rowSpacing: 7)
        #expect(layout.arrangement(sizes: sizes, width: 79).size == CGSize(width: 79, height: 84))
        #expect(layout.arrangement(sizes: sizes, width: 140).size == CGSize(width: 140, height: 40))
        #expect(layout.arrangement(sizes: [sizes[0]], width: 80).size == CGSize(width: 80, height: 20))
        #expect(layout.arrangement(sizes: [], width: 80).size == CGSize(width: 80, height: 0))
        #expect(layout.arrangement(sizes: [], width: nil).size == .zero)
        #expect(layout.arrangement(sizes: sizes, width: nil).size == CGSize(width: 140, height: 40))
        #expect(layout.arrangement(sizes: sizes, width: .infinity).size == CGSize(width: 140, height: 40))
    }

    @Test(arguments: [CGFloat(0), -1, 20])
    func oversizedCellsStartAtOriginAndOccupyTheirOwnRows(width: CGFloat) {
        let layout = WrappingLayout(rowAlignment: .top, spacing: 10, rowSpacing: 7)
        let result = layout.arrangement(sizes: sizes, width: width)
        #expect(result.frames.map(\.minX) == [0, 0, 0])
        #expect(result.frames.map(\.minY) == [0, 27, 74])
        #expect(result.size == CGSize(width: 50, height: 84))
    }

    @Test
    func wrappingRendersAllRowsOnTheFirstPass() throws {
        let actual = WrappingHStack(rowAlignment: .top, spacing: 10, rowSpacing: 7, cells) { cell in
            cell.color.frame(width: cell.size.width, height: cell.size.height)
        }
        .frame(width: 80)
        let expected = ZStack(alignment: .topLeading) {
            Color.red.frame(width: 40, height: 20)
            Color.green.frame(width: 30, height: 40).offset(x: 50)
            Color.blue.frame(width: 50, height: 10).offset(y: 47)
        }
        .frame(width: 80, height: 57, alignment: .topLeading)
        try compare(actual, expected, size: CGSize(width: 80, height: 57))
    }

    @Test(arguments: [CGSize(width: 80, height: 20), CGSize(width: 20, height: 80), CGSize(width: 40, height: 40)])
    func circleSizesAndCentersContentOnTheFirstPass(size: CGSize) throws {
        let side = max(size.width, size.height)
        let content = Color.blue.frame(width: size.width, height: size.height)
        let actual = content.circleBackground(fillColor: .yellow, borderColor: .red, borderWidth: 4)
        let shape = Circle()
        let expected = content
            .frame(width: side, height: side)
            .background(shape.fill(.yellow))
            .overlay(shape.stroke(.red, lineWidth: 4))
            .clipShape(shape)
        try compare(actual, expected, size: CGSize(width: side, height: side))
    }

    @Test
    func squareLayoutHandlesEmptyAndFlexibleContent() throws {
        let empty = SquareLayout { EmptyView() }.frame(width: 40, height: 40).background(.yellow)
        try compare(empty, Color.yellow.frame(width: 40, height: 40), size: CGSize(width: 40, height: 40))

        let renderer = ImageRenderer(content: Color.blue.circleBackground())
        renderer.proposedSize = ProposedViewSize(width: 120, height: 40)
        let image = try #require(renderer.cgImage)
        #expect(image.width == 120)
        #expect(image.height == 120)
    }

    @Test
    func wrappingPlacesChildrenInsideOffsetBounds() throws {
        let content = WrappingHStack(rowAlignment: .top, spacing: 10, rowSpacing: 7, Array(cells.prefix(2))) { cell in
            cell.color.frame(width: cell.size.width, height: cell.size.height)
        }
        .frame(width: 80)
        .padding(9)
        let expected = HStack(alignment: .top, spacing: 10) {
            Color.red.frame(width: 40, height: 20)
            Color.green.frame(width: 30, height: 40)
        }
        .padding(9)
        try compare(content, expected, size: CGSize(width: 98, height: 58))
    }

    private struct Cell: Identifiable {
        let id: Int
        let size: CGSize
        let color: Color
    }

    private var cells: [Cell] {
        zip(sizes.indices, [Color.red, .green, .blue]).map { Cell(id: $0, size: sizes[$0], color: $1) }
    }

    private func compare(_ actual: some View, _ expected: some View, size: CGSize) throws {
        let actualImage = try #require(ImageRenderer(content: actual).cgImage)
        let expectedImage = try #require(ImageRenderer(content: expected).cgImage)
        #expect(actualImage.width == Int(size.width))
        #expect(actualImage.height == Int(size.height))
        #expect(actualImage.width == expectedImage.width)
        #expect(actualImage.height == expectedImage.height)
        #expect(actualImage.bitsPerPixel == expectedImage.bitsPerPixel)
        let actualBytes = try #require(actualImage.dataProvider?.data) as Data
        let expectedBytes = try #require(expectedImage.dataProvider?.data) as Data
        let rowLength = actualImage.width * actualImage.bitsPerPixel / 8
        for row in 0..<actualImage.height {
            let actualStart = row * actualImage.bytesPerRow
            let expectedStart = row * expectedImage.bytesPerRow
            let difference = zip(
                actualBytes[actualStart..<(actualStart + rowLength)],
                expectedBytes[expectedStart..<(expectedStart + rowLength)]
            ).map { abs(Int($0) - Int($1)) }.max() ?? 0
            #expect(difference <= 1)
        }
    }
}
