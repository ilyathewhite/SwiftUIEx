import SwiftUI
import Testing
@testable import SwiftUIEx

@MainActor
struct RoundedRectBackgroundTests {
    @Test(arguments: [CGFloat(0), 8, 100])
    func fixedRadiusMatchesNativeShape(radius: CGFloat) {
        let shape = RoundedRectBackground.BackgroundShape(cornerRadius: .value(radius))
        for rect in bounds {
            #expect(shape.path(in: rect) == RoundedRectangle(cornerRadius: radius).path(in: rect))
        }
    }

    @Test
    func maximumRadiusFollowsCurrentHeightWithoutStateUpdates() {
        let shape = RoundedRectBackground.BackgroundShape(cornerRadius: .max)
        for rect in bounds {
            let expected = RoundedRectangle(cornerRadius: rect.height / 2).path(in: rect)
            #expect(shape.path(in: rect) == expected)
        }
    }

    @Test
    func fixedRadiusInterpolatesThroughAnimatableData() {
        var shape = RoundedRectBackground.BackgroundShape(cornerRadius: .value(4))
        #expect(shape.animatableData == 4)

        // Exercise intermediate animation values, not just the destination radius.
        for radius: CGFloat in [4, 8, 12, 16] {
            shape.animatableData = radius
            #expect(shape.animatableData == radius)
            for rect in bounds {
                #expect(shape.path(in: rect) == RoundedRectangle(cornerRadius: radius).path(in: rect))
            }
        }
    }

    @Test
    func maximumRadiusRemainsSizeDrivenDuringAnimation() {
        var shape = RoundedRectBackground.BackgroundShape(cornerRadius: .max)
        #expect(shape.animatableData == 0)
        shape.animatableData = 12
        #expect(shape.animatableData == 0)

        for rect in bounds {
            #expect(shape.path(in: rect) == RoundedRectangle(cornerRadius: rect.height / 2).path(in: rect))
        }
    }

    private var bounds: [CGRect] {
        [
            CGRect(x: 0, y: 0, width: 120, height: 40),
            CGRect(x: 0, y: 0, width: 40, height: 120),
            CGRect(x: 0, y: 0, width: 60, height: 60),
            CGRect(x: 10, y: 20, width: 120, height: 80),
            .zero
        ]
    }

    @Test(arguments: [false, true])
    func firstRenderMatchesNativeFillBorderAndClipping(maximum: Bool) throws {
        for size in [CGSize(width: 120, height: 40), CGSize(width: 40, height: 120)] {
            let radius: CGFloat = maximum ? size.height / 2 : 8
            let shape = RoundedRectangle(cornerRadius: radius)
            let content = Color.blue
                .frame(width: 20, height: 20)
                .frame(width: size.width, height: size.height, alignment: .topLeading)
            let actual = content.roundedRectBackground(
                fillColor: .yellow,
                borderColor: .red,
                cornerRadius: maximum ? .max : .value(8),
                borderWidth: 4
            )
            let expected = content
                .background(shape.fill(.yellow))
                .overlay(shape.stroke(.red, lineWidth: 4))
                .clipShape(shape)

            let actualImage = try #require(ImageRenderer(content: actual).cgImage)
            let expectedImage = try #require(ImageRenderer(content: expected).cgImage)
            #expect(actualImage.width == Int(size.width))
            #expect(actualImage.height == Int(size.height))
            let actualData = try #require(actualImage.dataProvider?.data)
            let expectedData = try #require(expectedImage.dataProvider?.data)
            #expect(actualImage.bitsPerPixel == expectedImage.bitsPerPixel)
            let pixelBytesPerRow = actualImage.width * actualImage.bitsPerPixel / 8
            let actualBytes = actualData as Data
            let expectedBytes = expectedData as Data
            for row in 0..<actualImage.height {
                let actualStart = row * actualImage.bytesPerRow
                let expectedStart = row * expectedImage.bytesPerRow
                // Allow one quantization step at antialiased edges.
                let maximumDifference = zip(
                    actualBytes[actualStart..<(actualStart + pixelBytesPerRow)],
                    expectedBytes[expectedStart..<(expectedStart + pixelBytesPerRow)]
                ).map { abs(Int($0) - Int($1)) }.max() ?? 0
                #expect(maximumDifference <= 1)
            }
        }
    }
}
