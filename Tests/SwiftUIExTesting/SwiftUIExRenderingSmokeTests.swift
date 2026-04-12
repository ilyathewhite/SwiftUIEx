//
//  SwiftUIExRenderingSmokeTests.swift
//
//  Created by Codex on 4/11/26.
//

#if os(macOS)

import SwiftUI
import Testing
@testable import SwiftUIEx

import AppKit

@MainActor
@Suite(.serialized)
struct SwiftUIExRenderingSmokeTests {
    @Test
    func rendersCommonViewModifiersAndAnimationViews() {
        var sideEffectCount = 0
        var trigger = ActionTrigger()
        let triggerBinding = Binding(get: {
            trigger
        }, set: {
            trigger = $0
        })

        render(
            VStack {
                Text("top")
                    .sideEffect { sideEffectCount += 1 }
                    .topDivider()
                    .focusableHidingRing()
                    .windowTitle("Window")
                    .showIf(true, animation: .default)
                    .roundedRectBackground(fillColor: .yellow, borderColor: .blue, cornerRadius: .value(8), borderWidth: 2)
                    .circleBackground(fillColor: .green, borderColor: .red, borderWidth: 1)
                    .accentColorSelection(isSelected: true)
                    .underlineSelection(isSelected: false)
                    .silhouetteInverseFill(color: .purple)
                    .testIdentifier("top.text")
                    .actionTrigger(triggerBinding) {}
                    .connectOnAppear {}
                    .onAppear(isConnected: { true }) {}

                Text("dark selected")
                    .accentColorSelection(isSelected: true)
                    .environment(\.colorScheme, .dark)

                Text("max radius")
                    .roundedRectBackground(fillColor: .orange)

                Text("hidden connect")
                    .connectOnAppear {}
                    .environment(\.isHidden, true)

                Text("hidden connect allowed")
                    .connectOnAppear(connectIfHidden: true) {}
                    .environment(\.isHidden, true)

                Text("hidden")
                    .showIf(false)

                Text("measurements")
                    .heightMeasurement(HeightKey.self)
                    .safeAreaInsetsMeasurement(InsetsKey.self)
                    .measure(GenericKey.self, { _ in 7 }) { _ in }
                    .measureHeight(HeightKey.self) { _ in }
                    .measureSafeAreaInsets(InsetsKey.self) { _ in }

                Text("animated")
                    .animatedOpacity(trigger: .init(rawValue: 0.25), progressEvaluator: .zero_one_zero_sin)
                    .animatedZRotation(maxAngle: .pi, trigger: .init(rawValue: 0.5), progressEvaluator: .one_zero_one3)

                CopyButton(RenderClipboardPayload(text: "copy"))
                CopyButton<RenderClipboardPayload>(nil)

                AnimatedStateChangeView()
                DeferredOnAppearView()
                RetryingOnAppearView()
            }
        )

        #expect(sideEffectCount == 1)
    }

    @Test
    func rendersCompositeViewsInRepresentativeStates() {
        var showHint = true
        var showDetail = false
        let items = [
            DemoRenderItem(id: 1, title: "One"),
            DemoRenderItem(id: 2, title: "Two"),
            DemoRenderItem(id: 3, title: "Three")
        ]
        let selection = Binding<DemoRenderItem?>(get: {
            items[1]
        }, set: { _ in })

        let path = Path { path in
            path.move(to: .init(x: 0, y: 0))
            path.addLine(to: .init(x: 20, y: 20))
        }

        render(
            ZStack {
                BottomHintView(
                    show: Binding(get: { showHint }, set: { showHint = $0 }),
                    text: "Saved",
                    color: .blue,
                    zIndex: 10
                )

                NavigationRow("Details") {}
                    .frame(height: 44)

                NavigationRow(LocalizedStringKey("Localized")) {}
                    .frame(height: 44)

                NavigationRow(action: {}, label: {
                    Text("Closure")
                })
                .frame(height: 44)

                DetailContainerView {
                    Text("Detail")
                }

                MasterDetailView(
                    master: { Text("Master") },
                    detail: {
                        DetailContainerView {
                            Text("Detail")
                        }
                    },
                    masterWidth: 120,
                    showAll: true,
                    showDetail: Binding(get: { showDetail }, set: { showDetail = $0 })
                )

                Collection<RenderCell>(
                    content: items,
                    selection: selection,
                    columnCount: 2,
                    columnSpacing: 4,
                    rowSpacing: 6
                )

                HCollection<RenderCell>(
                    content: items,
                    selection: selection,
                    spacing: 5
                )

                WrappingHStack(items) { item in
                    Text(item.title)
                        .padding(4)
                }

                AnimatablePath(
                    path: path,
                    end: 0.75,
                    strokeStyle: .init(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )

                Animated(Binding(get: { showHint }, set: { showHint = $0 }), with: { _ in .default }) { value in
                    Text(value ? "On" : "Off")
                }
            }
            .frame(width: 500, height: 500)
        )

        showHint = false
        showDetail = true

        render(
            VStack {
                BottomHintView(
                    show: Binding(get: { showHint }, set: { showHint = $0 }),
                    text: "Saved",
                    color: .blue,
                    zIndex: 10
                )
                MasterDetailView(
                    master: { Text("Master") },
                    detail: {
                        DetailContainerView {
                            Text("Detail")
                        }
                    },
                    masterWidth: 120,
                    showAll: false,
                    showDetail: Binding(get: { showDetail }, set: { showDetail = $0 })
                )
            }
            .frame(width: 300, height: 300)
        )
    }

    @Test
    func rendersRepresentableAndTextFieldViews() {
        var text = "Hello"

        render(
            VStack {
                StyledTextField(
                    text: Binding(get: { text }, set: { text = $0 }),
                    configure: { $0.placeholderString = "Placeholder" }
                )
                .frame(width: 200, height: 30)

                Text("Tagged")
                    .testIdentifier("tagged")
            }
            .frame(width: 240, height: 80)
        )
    }

}

private enum HeightTag {}
private enum InsetsTag {}
private enum GenericTag {}
private typealias HeightKey = MeasurementKey<CGFloat, HeightTag>
private typealias InsetsKey = MeasurementKey<EdgeInsets, InsetsTag>
private typealias GenericKey = MeasurementKey<Int, GenericTag>

private struct DemoRenderItem: Identifiable, Equatable {
    let id: Int
    let title: String
}

private struct RenderCell: CollectionCell {
    let value: DemoRenderItem
    let selection: DemoRenderItem?
    let env: Void

    init(value: DemoRenderItem, selection: Binding<DemoRenderItem?>, env: Void) {
        self.value = value
        self.selection = selection.wrappedValue
        self.env = env
    }

    var body: some View {
        Text(value.title)
            .accentColorSelection(isSelected: isSelected)
            .padding(4)
    }
}

private struct RenderClipboardPayload: TransferableEx {
    let text: String

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.text)
    }

    var pasteboardItem: NSPasteboardItem {
        let item = NSPasteboardItem()
        item.setString(text, forType: .string)
        return item
    }

    var exportPreview: SharePreview<Never, String> {
        SharePreview("Render Clipboard Payload", icon: text)
    }
}

private struct AnimatedStateChangeView: View {
    @State private var value = false

    var body: some View {
        Animated($value, with: { _ in .default }) { value in
            Text(value ? "Changed" : "Initial")
        }
        .onAppear {
            value = true
        }
    }
}

private struct DeferredOnAppearView: View {
    @State private var connected = false
    @State private var actionCount = 0

    var body: some View {
        Text("\(actionCount)")
            .onAppear(isConnected: { connected }) {
                actionCount += 1
            }
            .onAppear {
                connected = true
            }
    }
}

private struct RetryingOnAppearView: View {
    @State private var attempts = 0
    @State private var actionCount = 0

    var body: some View {
        Text("\(actionCount)")
            .onAppear(isConnected: {
                attempts += 1
                return attempts >= 3
            }) {
                actionCount += 1
            }
    }
}

@MainActor
private func render<V: View>(_ view: V, size: CGSize = .init(width: 600, height: 600)) {
    let host = NSHostingView(rootView: view)
    host.frame = .init(origin: .zero, size: size)
    host.needsLayout = true
    host.layoutSubtreeIfNeeded()
    _ = host.fittingSize
    RunLoop.main.run(until: Date().addingTimeInterval(0.03))
}

#elseif os(iOS)

import SwiftUI
import Testing
@testable import SwiftUIEx

import UIKit

@MainActor
@Suite(.serialized)
struct SwiftUIExIOSRenderingSmokeTests {
    @Test
    func rendersCommonViewModifiersAndAnimationViews() {
        var sideEffectCount = 0
        var trigger = ActionTrigger()
        let triggerBinding = Binding(get: {
            trigger
        }, set: {
            trigger = $0
        })

        render(
            VStack {
                Text("top")
                    .sideEffect { sideEffectCount += 1 }
                    .topDivider()
                    .showIf(true, animation: .default)
                    .roundedRectBackground(fillColor: .yellow, borderColor: .blue, cornerRadius: .value(8), borderWidth: 2)
                    .circleBackground(fillColor: .green, borderColor: .red, borderWidth: 1)
                    .accentColorSelection(isSelected: true)
                    .underlineSelection(isSelected: false)
                    .silhouetteInverseFill(color: .purple)
                    .testIdentifier("top.text")
                    .actionTrigger(triggerBinding) {}
                    .connectOnAppear {}
                    .onAppear(isConnected: { true }) {}

                Text("dark selected")
                    .accentColorSelection(isSelected: true)
                    .environment(\.colorScheme, .dark)

                Text("max radius")
                    .roundedRectBackground(fillColor: .orange)

                Text("hidden connect")
                    .connectOnAppear {}
                    .environment(\.isHidden, true)

                Text("hidden connect allowed")
                    .connectOnAppear(connectIfHidden: true) {}
                    .environment(\.isHidden, true)

                Text("hidden")
                    .showIf(false)

                Text("measurements")
                    .heightMeasurement(HeightKey.self)
                    .safeAreaInsetsMeasurement(InsetsKey.self)
                    .measure(GenericKey.self, { _ in 7 }) { _ in }
                    .measureHeight(HeightKey.self) { _ in }
                    .measureSafeAreaInsets(InsetsKey.self) { _ in }

                Text("animated")
                    .animatedOpacity(trigger: .init(rawValue: 0.25), progressEvaluator: .zero_one_zero_sin)
                    .animatedZRotation(maxAngle: .pi, trigger: .init(rawValue: 0.5), progressEvaluator: .one_zero_one3)

                CopyButton(RenderClipboardPayload(text: "copy"))
                CopyButton<RenderClipboardPayload>(nil)

                AnimatedStateChangeView()
                DeferredOnAppearView()
                RetryingOnAppearView()
            }
        )

        #expect(sideEffectCount == 1)
    }

    @Test
    func rendersCompositeViewsInRepresentativeStates() {
        var showHint = true
        var showDetail = false
        let items = [
            DemoRenderItem(id: 1, title: "One"),
            DemoRenderItem(id: 2, title: "Two"),
            DemoRenderItem(id: 3, title: "Three")
        ]
        let selection = Binding<DemoRenderItem?>(get: {
            items[1]
        }, set: { _ in })

        let path = Path { path in
            path.move(to: .init(x: 0, y: 0))
            path.addLine(to: .init(x: 20, y: 20))
        }

        render(
            ZStack {
                BottomHintView(
                    show: Binding(get: { showHint }, set: { showHint = $0 }),
                    text: "Saved",
                    color: .blue,
                    zIndex: 10
                )

                NavigationRow("Details") {}
                    .frame(height: 44)

                NavigationRow(LocalizedStringKey("Localized")) {}
                    .frame(height: 44)

                NavigationRow(action: {}, label: {
                    Text("Closure")
                })
                .frame(height: 44)

                DetailContainerView {
                    Text("Detail")
                }

                MasterDetailView(
                    master: { Text("Master") },
                    detail: {
                        DetailContainerView {
                            Text("Detail")
                        }
                    },
                    masterWidth: 120,
                    showAll: true,
                    showDetail: Binding(get: { showDetail }, set: { showDetail = $0 })
                )

                Collection<RenderCell>(
                    content: items,
                    selection: selection,
                    columnCount: 2,
                    columnSpacing: 4,
                    rowSpacing: 6
                )

                HCollection<RenderCell>(
                    content: items,
                    selection: selection,
                    spacing: 5
                )

                WrappingHStack(items) { item in
                    Text(item.title)
                        .padding(4)
                }

                AnimatablePath(
                    path: path,
                    end: 0.75,
                    strokeStyle: .init(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )

                Animated(Binding(get: { showHint }, set: { showHint = $0 }), with: { _ in .default }) { value in
                    Text(value ? "On" : "Off")
                }
            }
            .frame(width: 500, height: 500)
        )

        showHint = false
        showDetail = true

        render(
            VStack {
                BottomHintView(
                    show: Binding(get: { showHint }, set: { showHint = $0 }),
                    text: "Saved",
                    color: .blue,
                    zIndex: 10
                )
                MasterDetailView(
                    master: { Text("Master") },
                    detail: {
                        DetailContainerView {
                            Text("Detail")
                        }
                    },
                    masterWidth: 120,
                    showAll: false,
                    showDetail: Binding(get: { showDetail }, set: { showDetail = $0 })
                )
            }
            .frame(width: 300, height: 300)
        )
    }

    @Test
    func rendersRepresentableAndTextFieldViews() {
        var text = "Hello"
        var customValue: String? = "value"
        var typedText = "Typed"
        var capturedWindow: UIWindow?
        var customCanPerformCopy: Bool?
        let recorder = RenderCustomInputRecorder()

        render(
            VStack {
                StyledTextField(
                    text: Binding(get: { text }, set: { text = $0 }),
                    configure: { $0.placeholder = "Placeholder" }
                )
                .frame(width: 200, height: 30)

                CustomInputTextField(
                    value: Binding(get: { customValue }, set: { customValue = $0 }),
                    typedText: Binding(get: { typedText }, set: { typedText = $0 }),
                    configure: {
                        $0.placeholder = "Custom"
                        customCanPerformCopy = $0.canPerformAction(
                            #selector(UIResponderStandardEditActions.copy(_:)),
                            withSender: nil
                        )
                    },
                    inputView: { RenderCustomInputView(recorder: recorder) }
                )
                .frame(width: 200, height: 30)

                WindowReader(window: Binding(get: {
                    capturedWindow
                }, set: {
                    capturedWindow = $0
                }))
                .frame(width: 1, height: 1)

                Text("Tagged")
                    .testIdentifier("tagged")
            }
            .frame(width: 240, height: 100)
        )

        #expect(customCanPerformCopy == false)
    }
}

@MainActor
private final class RenderCustomInputRecorder {
    var clearCount = 0
}

private struct RenderCustomInputView: CustomInputView {
    let recorder: RenderCustomInputRecorder

    func updateValue(_ value: String?) {
    }

    func updateTypedText(_ text: String) {
    }

    func clear() {
        recorder.clearCount += 1
    }

    func hide() {
    }

    var body: some View {
        Text("Custom Input")
    }
}

private enum HeightTag {}
private enum InsetsTag {}
private enum GenericTag {}
private typealias HeightKey = MeasurementKey<CGFloat, HeightTag>
private typealias InsetsKey = MeasurementKey<EdgeInsets, InsetsTag>
private typealias GenericKey = MeasurementKey<Int, GenericTag>

private struct DemoRenderItem: Identifiable, Equatable {
    let id: Int
    let title: String
}

private struct RenderCell: CollectionCell {
    let value: DemoRenderItem
    let selection: DemoRenderItem?
    let env: Void

    init(value: DemoRenderItem, selection: Binding<DemoRenderItem?>, env: Void) {
        self.value = value
        self.selection = selection.wrappedValue
        self.env = env
    }

    var body: some View {
        Text(value.title)
            .accentColorSelection(isSelected: isSelected)
            .padding(4)
    }
}

private struct RenderClipboardPayload: TransferableEx {
    let text: String

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.text)
    }

    var exportPreview: SharePreview<Never, String> {
        SharePreview("Render Clipboard Payload", icon: text)
    }
}

private struct AnimatedStateChangeView: View {
    @State private var value = false

    var body: some View {
        Animated($value, with: { _ in .default }) { value in
            Text(value ? "Changed" : "Initial")
        }
        .onAppear {
            value = true
        }
    }
}

private struct DeferredOnAppearView: View {
    @State private var connected = false
    @State private var actionCount = 0

    var body: some View {
        Text("\(actionCount)")
            .onAppear(isConnected: { connected }) {
                actionCount += 1
            }
            .onAppear {
                connected = true
            }
    }
}

private struct RetryingOnAppearView: View {
    @State private var attempts = 0
    @State private var actionCount = 0

    var body: some View {
        Text("\(actionCount)")
            .onAppear(isConnected: {
                attempts += 1
                return attempts >= 3
            }) {
                actionCount += 1
            }
    }
}

@MainActor
private func render<V: View>(_ view: V, size: CGSize = .init(width: 600, height: 600)) {
    let window = UIWindow(frame: .init(origin: .zero, size: size))
    let rootController = UIViewController()
    let host = UIHostingController(rootView: view)

    window.rootViewController = rootController
    rootController.view.frame = window.bounds
    rootController.addChild(host)
    rootController.view.addSubview(host.view)
    host.view.frame = rootController.view.bounds
    host.view.backgroundColor = .clear
    host.didMove(toParent: rootController)

    window.makeKeyAndVisible()
    host.view.setNeedsLayout()
    host.view.layoutIfNeeded()
    RunLoop.main.run(until: Date().addingTimeInterval(0.05))

    host.willMove(toParent: nil)
    host.view.removeFromSuperview()
    host.removeFromParent()
    window.isHidden = true
}

#endif
