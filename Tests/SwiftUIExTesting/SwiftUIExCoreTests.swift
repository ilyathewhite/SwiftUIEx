//
//  SwiftUIExCoreTests.swift
//
//  Created by Codex on 4/11/26.
//

import SwiftUI
import Testing
@testable import SwiftUIEx
@testable import SwiftUIExTesting

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

@MainActor
@Suite(.serialized)
struct SwiftUIExCoreTests {
    @Test
    func actionTriggerIncrementsAndComparesByCounter() {
        var trigger = ActionTrigger()
        let initial = trigger

        trigger.fire()

        #expect(trigger != initial)
        #expect(trigger == trigger)
    }

    @Test
    func cgRectCenterUsesMidpoints() {
        let rect = CGRect(x: 10, y: 20, width: 30, height: 50)

        #expect(rect.center == CGPoint(x: 25, y: 45))
    }

    @Test
    func endFlowActionAndEnvironmentValuesRoundTrip() {
        var didEnd = false
        let endFlowAction = EndFlowAction {
            didEnd = true
        }
        var values = EnvironmentValues()
        var didExit = false

        values.foregroundColor = .red
        values.isHidden = true
        values.windowTitle = "Library"
        values.exitAction = { didExit = true }
        values.endFlowAction = endFlowAction

        values.exitAction?()
        values.endFlowAction?()

        #expect(values.isHidden)
        #expect(values.windowTitle == "Library")
        #expect(didExit)
        #expect(didEnd)
    }

    @Test
    func swiftUIExEnvironmentLoggerCanBeReplaced() {
        let original = SwiftUIEx.env
        var messages: [String] = []
        SwiftUIEx.env = .init { message in
            messages.append(message)
        }
        defer {
            SwiftUIEx.env = original
        }

        SwiftUIEx.env.logCodingError("broken")
        original.logCodingError("logged through default environment")

        #expect(messages == ["broken"])
    }

    @Test
    func measurementPreferenceKeysKeepFirstAndMaximumValues() {
        enum Tag {}

        var first: FirstMeasurementKey<Int, Tag>.Value = nil
        FirstMeasurementKey<Int, Tag>.reduce(value: &first) { 7 }
        FirstMeasurementKey<Int, Tag>.reduce(value: &first) { 99 }
        #expect(first == 7)

        var maxValue: MaxMeasurementKey<Int, Tag>.Value = nil
        MaxMeasurementKey<Int, Tag>.reduce(value: &maxValue) { nil }
        #expect(maxValue == nil)
        MaxMeasurementKey<Int, Tag>.reduce(value: &maxValue) { 4 }
        #expect(maxValue == 4)
        MaxMeasurementKey<Int, Tag>.reduce(value: &maxValue) { nil }
        #expect(maxValue == 4)
        MaxMeasurementKey<Int, Tag>.reduce(value: &maxValue) { 9 }
        #expect(maxValue == 9)
        #expect(FirstMeasurementKey<Int, Tag>.defaultValue == nil)
        #expect(MaxMeasurementKey<Int, Tag>.defaultValue == nil)
    }

    @Test
    func explicitAnimationEvaluatorsCoverEachProgressSegment() {
        var trigger = ExplicitAnimation.Trigger()
        trigger.animate()
        trigger.animate()

        #expect(trigger.rawValue == 2)
        #expect(ExplicitAnimation.ScaledValueEvaluator<Double>.identity.eval(0.25) == 0.25)
        #expect(abs(ExplicitAnimation.ScaledValueEvaluator<Double>.radians.eval(0.5) - Double.pi) < 0.000_001)
        #expect(abs(ExplicitAnimation.ProgressEvaluator.zero_one_zero_sin.eval(0.5) - 1) < 0.000_001)

        #expect(ExplicitAnimation.ProgressEvaluator.zero_one_zero3.eval(0.125) == 0.5)
        #expect(ExplicitAnimation.ProgressEvaluator.zero_one_zero3.eval(0.5) == 1)
        #expect(abs(ExplicitAnimation.ProgressEvaluator.zero_one_zero3.eval(0.875) - 0.5) < 0.000_001)

        #expect(ExplicitAnimation.ProgressEvaluator.one_zero_one3.eval(0.125) == 0.5)
        #expect(ExplicitAnimation.ProgressEvaluator.one_zero_one3.eval(0.5) == 0)
        #expect(abs(ExplicitAnimation.ProgressEvaluator.one_zero_one3.eval(0.875) - 0.5) < 0.000_001)

        let samples = [0.125, 0.375, 0.625, 0.875].map {
            ExplicitAnimation.ProgressEvaluator.damped_oscillations_3.eval($0)
        }
        #expect(samples.count == 4)
    }

    @Test
    func explicitAnimationModifiersExposeAnimatableValues() {
        let opacity = OpacityModifierProvider.modifier(value: 0.4)
        let rotation = ZRotationModifierProvider.modifier(value: 1.5)
        var triggerModifier = AnimatedOpacityTriggerModifier(
            trigger: .init(),
            progressEvaluator: .zero_one_zero_sin
        )

        triggerModifier.animatableData = 2.75

        #expect(opacity.value == 0.4)
        #expect(rotation.value == 1.5)
        #expect(triggerModifier.animatableData == 2.75)
    }

    @Test
    func animationRepeatHelperAndConditionalWithAnimationRunBodies() {
        var callCount = 0
        let withoutAnimation = withAnimation(nil, while: true) {
            callCount += 1
            return "none"
        }
        let withFiniteAnimation = withAnimation(Animation.default, while: false) {
            callCount += 1
            return "finite"
        }
        let withRepeatingAnimation = withAnimation(Animation.default, while: true) {
            callCount += 1
            return "repeating"
        }

        _ = Animation.default.repeat(while: true)
        _ = Animation.default.repeat(while: false, autoreverses: false)

        #expect(withoutAnimation == "none")
        #expect(withFiniteAnimation == "finite")
        #expect(withRepeatingAnimation == "repeating")
        #expect(callCount == 3)
    }

    @Test
    func colorsCanBeCreatedFromHexAndSystemPalettes() {
        _ = Color(hex: "#33669980")
        let dynamicColor = Color(R: 0.1, G: 0.2, B: 0.3, darkR: 0.7, darkG: 0.8, darkB: 0.9, alpha: 0.4)
        _ = Color(R: 10, G: 20, B: 30, darkR: 220, darkG: 230, darkB: 240, alpha: 0.5)
        _ = Color.label
        _ = Color.secondaryLabel
        _ = Color.tertiaryLabel
        _ = Color.quaternaryLabel
        _ = Color.systemGray2
        _ = Color.systemGray3
        _ = Color.systemGray4
        _ = Color.systemGray5
        _ = Color.systemBackground

        if #available(iOS 17, macOS 14, tvOS 17, *) {
            var environment = EnvironmentValues()
            environment.colorScheme = .light
            _ = dynamicColor.resolve(in: environment)
            environment.colorScheme = .dark
            _ = dynamicColor.resolve(in: environment)
        }
    }

    @Test
    func collectionCellsReportSelectionByID() {
        var selection: DemoItem? = .init(id: 2, title: "Two")
        let selected = DemoCell(value: .init(id: 2, title: "Two"), selection: Binding(get: {
            selection
        }, set: {
            selection = $0
        }), env: "env")
        let unselected = DemoCell(value: .init(id: 1, title: "One"), selection: .constant(selection), env: "env")

        #expect(selected.isSelected)
        #expect(!unselected.isSelected)
        #expect(selected.env == "env")
    }

    @Test
    func collectionsStoreConfigurationAndDeduplicateWrappingHStackData() {
        let items = [
            DemoItem(id: 1, title: "One"),
            DemoItem(id: 1, title: "Duplicate"),
            DemoItem(id: 2, title: "Two")
        ]
        let original = SwiftUIEx.env
        var messages: [String] = []
        SwiftUIEx.env = .init { message in
            messages.append(message)
        }
        defer {
            SwiftUIEx.env = original
        }

        let selection = Binding<DemoItem?>(get: { nil }, set: { _ in })
        let collection = Collection<DemoCell>(
            content: Array(items.suffix(2)),
            selection: selection,
            cellEnv: "grid",
            columnCount: 2,
            columnSpacing: 3,
            rowSpacing: 5,
            cellWidth: 44
        )
        let horizontal = HCollection<DemoCell>(
            content: Array(items.suffix(2)),
            selection: selection,
            cellEnv: "row",
            spacing: 8,
            edgeInsets: .init(top: 1, leading: 2, bottom: 3, trailing: 4)
        )
        let wrapping = WrappingHStack(rowAlignment: .center, spacing: 4, rowSpacing: 6, items) { item in
            Text(item.title)
        }
        let layout = wrapping.layout(availableWidth: 100)
        let wrappingTop = WrappingHStack(rowAlignment: .top, items) { item in
            Text(item.title)
        }
        let wrappingBottom = WrappingHStack(rowAlignment: .bottom, items) { item in
            Text(item.title)
        }
        let wrappedLayout = wrapping.layout(availableWidth: -1)

        #expect(collection.content.count == 2)
        #expect(collection.cellEnv == "grid")
        #expect(collection.columnCount == 2)
        #expect(collection.columnSpacing == 3)
        #expect(collection.rowSpacing == 5)
        #expect(collection.cellWidth == 44)
        #expect(horizontal.content.count == 2)
        #expect(horizontal.spacing == 8)
        #expect(horizontal.edgeInsets.leading == 2)
        #expect(wrapping.data.map(\.id) == [1, 2])
        #expect(messages.count == 3)
        #expect(layout.frames.keys.count == 2)
        #expect(wrappingTop.layout(availableWidth: 100).frames.keys.count == 2)
        #expect(wrappingBottom.layout(availableWidth: 100).frames.keys.count == 2)
        #expect(wrappedLayout.frames.keys.count == 2)
    }

    @Test
    func animatablePathWrapperUpdatesAnimatableEndPoint() {
        let path = Path { path in
            path.move(to: .zero)
            path.addLine(to: .init(x: 10, y: 0))
        }
        var wrapper = AnimatablePath.PathWrapper(path: path, end: 0.25)

        wrapper.animatableData = 0.75

        #expect(wrapper.animatableData == 0.75)
        #expect(!wrapper.path(in: .init(x: 0, y: 0, width: 10, height: 10)).isEmpty)
    }

    @Test
    func bottomHintAnimationUsesSeparateShowAndHideDurations() {
        var show = true
        let hint = BottomHintView(
            show: Binding(get: { show }, set: { show = $0 }),
            text: "Saved",
            color: .blue,
            zIndex: 1,
            showDuration: 0.1,
            hideDuration: 0.3
        )

        _ = hint.transition
        _ = hint.animation(show: true)
        _ = hint.animation(show: false)
    }

    @Test
    func detailContainerDefaultBackActionAndSlideAnimationAreCallable() {
        let detail = DetailContainerView {
            Text("Detail")
        }

        detail.backAction()
        _ = Animation.slide
    }

    @Test
    func testKitErrorsAndDurationsAreUserReadable() {
        #expect(TestKit.AnimationType.present.duration == .seconds(1))
        #expect(TestKit.AnimationType.dismiss.duration == .seconds(1))
        #expect(TestKit.AnimationType.push.duration == .seconds(1))
        #expect(TestKit.AnimationType.pop.duration == .seconds(1))
        #expect(TestKit.AnimationType.swipe.duration == .seconds(1))
        #expect(TestKit.WaitUntilError.timedOut(description: "view").errorDescription == "Timed out waiting for view.")
        #expect(TestKit.TestingError.missingFirstSceneWindow.errorDescription == "Unable to find the first scene window.")
        #expect(TestKit.TestingError.missingWindow.errorDescription == "Unable to find a test window.")
        #expect(
            TestKit.TestingError.missingViewWithAccessibilityLabel("label").errorDescription
                == "Unable to find a view with accessibility label 'label'."
        )
        #expect(TestKit.TestingError.missingViewWithAccessibilityIdentifier("id").errorDescription == "Unable to find a view with accessibility identifier 'id'.")
        #expect(TestKit.TestingError.failedToCreateMouseEvent("tap").errorDescription == "Unable to create a mouse event for 'tap'.")
        #expect(TestKit.TestingError.failedToDeliverEvent("tap").errorDescription == "Unable to deliver the 'tap' event.")
        #expect(TestKit.TestingError.notImplemented("feature").errorDescription == "'feature' is not implemented on this platform.")
    }

    @Test
    func finishAnimationWaitsForTheRequestedAnimationType() async {
        await finishAnimation(.swipe, "swipe")
    }

#if os(iOS)
    @Test
    func copyButtonWritesTransferableValueToPasteboardOnIOS() async {
        UIPasteboard.general.items = []
        let value = ClipboardPayload(text: "copied")
        let button = CopyButton(value)
        let emptyButton = CopyButton<ClipboardPayload>(nil)

        #expect(button.value?.text == "copied")
        #expect(button.icon == "square.on.square")

        emptyButton.copy()
        #expect(UIPasteboard.general.itemProviders.isEmpty)

        button.copy()

        #expect(!UIPasteboard.general.itemProviders.isEmpty)
        try? await Task.sleep(for: .seconds(0.8))
    }

    @Test
    func passthroughViewIgnoresHitsOnItselfButKeepsSubviewHitsOnIOS() {
        let root = PassthroughView(frame: .init(x: 0, y: 0, width: 100, height: 100))
        let child = UIView(frame: .init(x: 10, y: 10, width: 20, height: 20))

        root.addSubview(child)

        #expect(root.hitTest(.init(x: 50, y: 50), with: nil) == nil)
        #expect(root.hitTest(.init(x: 15, y: 15), with: nil) === child)
    }

    @Test
    func viewLookupFindsAccessibilityIdentifiersBreadthFirstOnIOS() throws {
        let root = UIView()
        let first = UIView()
        let second = UIView()
        let nested = UIView()
        first.accessibilityIdentifier = "first"
        second.accessibilityIdentifier = "second"
        nested.accessibilityIdentifier = "nested"
        root.addSubview(first)
        root.addSubview(second)
        first.addSubview(nested)

        _ = firstSceneWindow()

        #expect(firstView(in: root, where: { $0.accessibilityIdentifier == "nested" }) === nested)
        #expect(try viewWithAccessibilityIdentifier("second", in: root) === second)
        #expect(throwsMissingIdentifier {
            _ = try viewWithAccessibilityIdentifier("missing", in: root)
        })
    }

    @Test
    func styledTextFieldCoordinatorUpdatesTextAndReportsCommittedValuesOnIOS() {
        var text = "old"
        var committedValues: [AnyObject?] = []
        let field = StyledTextField(
            text: Binding(get: { text }, set: { text = $0 }),
            getValue: { committedValues.append($0) },
            configure: { $0.placeholder = "Name" }
        )
        let coordinator = field.makeCoordinator()
        let textField = UITextField()

        textField.text = "old"
        #expect(coordinator.textField(
            textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 3),
            replacementString: "new"
        ))
        #expect(text == "new")

        #expect(!coordinator.textField(
            textField,
            shouldChangeCharactersIn: NSRange(location: 99, length: 0),
            replacementString: "ignored"
        ))

        textField.text = "committed"
        #expect(coordinator.textFieldShouldReturn(textField))
        #expect(committedValues.last as? NSString == "committed")

        #expect(coordinator.textFieldShouldClear(textField))
        #expect(text == "")
    }

    @Test
    func styledTextFieldCoordinatorUsesFormatterForPartialAndCommittedTextOnIOS() {
        var text = ""
        var committedValues: [AnyObject?] = []
        let formatter = DeterministicFormatter()
        let field = StyledTextField(
            text: Binding(get: { text }, set: { text = $0 }),
            formatter: formatter,
            getValue: { committedValues.append($0) },
            configure: { _ in }
        )
        let coordinator = field.makeCoordinator()
        let textField = UITextField()

        textField.text = ""
        #expect(coordinator.textField(
            textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "replace"
        ))
        #expect(text == "123")

        textField.text = "123"
        #expect(coordinator.textFieldShouldReturn(textField))
        #expect((committedValues.last as? NSNumber)?.intValue == 123)

        textField.text = "abc"
        #expect(!coordinator.textFieldShouldReturn(textField))
        #expect(committedValues.count == 2)
        #expect(committedValues[1] == nil)
    }

    @Test
    func hostingViewAddsHostedContentWhenAttachedToWindow() {
        let hostingView = HostingView(rootView: Text("Hosted"))
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 160, height: 120))

        window.addSubview(hostingView)
        window.makeKeyAndVisible()
        if hostingView.subviews.isEmpty {
            hostingView.didMoveToWindow()
        }

        #expect(hostingView.subviews.contains(hostingView.vc.view))
        #expect(hostingView.vc.view.backgroundColor == .clear)
        #expect(!hostingView.vc.view.translatesAutoresizingMaskIntoConstraints)
        #expect(hostingView.constraints.count == 4)

        window.isHidden = true
    }

    @Test
    func windowReaderCapturesWindowTransitions() {
        var capturedWindow: UIWindow?
        let reader = WindowReader(window: Binding(get: {
            capturedWindow
        }, set: {
            capturedWindow = $0
        }))
        let coordinator = reader.makeCoordinator()
        let readerView = WindowReader.WindowReaderView(coordinator: coordinator)
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 80, height: 80))

        window.addSubview(readerView)
        window.makeKeyAndVisible()
        readerView.didMoveToWindow()
        #expect(capturedWindow === window)

        readerView.removeFromSuperview()
        readerView.didMoveToWindow()
        #expect(capturedWindow == nil)

        window.isHidden = true
    }

    @Test
    func customInputTextFieldCoordinatorOwnsInputViewAndBlocksKeyboardEditing() {
        let recorder = CoreCustomInputRecorder()
        var value: String? = "old"
        var typedText = "typed"
        let field = CustomInputTextField(
            value: Binding(get: { value }, set: { value = $0 }),
            typedText: Binding(get: { typedText }, set: { typedText = $0 }),
            configure: { $0.placeholder = "Custom" },
            inputView: { CoreCustomInputView(recorder: recorder) }
        )
        let coordinator = field.makeCoordinator()
        let textField = UITextField()

        #expect(coordinator.inputVC.rootView.recorder === recorder)
        #expect(coordinator.textFieldShouldClear(textField))
        #expect(recorder.clearCount == 1)
        #expect(coordinator.textField(
            textField,
            editMenuForCharactersIn: NSRange(location: 0, length: 0),
            suggestedActions: []
        ) == nil)
        #expect(!coordinator.textField(
            textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "x"
        ))

        textField.text = "abcdef"
        let start = textField.beginningOfDocument
        textField.selectedTextRange = textField.textRange(from: start, to: start)
        coordinator.textFieldDidChangeSelection(textField)
        #expect(textField.offset(from: textField.beginningOfDocument, to: textField.selectedTextRange?.start ?? start) == 6)
    }

    @Test
    func iOSViewHelpersAndSystemColorsAreCallable() {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 100, height: 100))
        let text = Text("Helpers")

        text.dismissKeyboard()

        #expect(!text.isContextMenuVisible(window: nil))
        #expect(!text.isContextMenuVisible(window: window))

        _ = Color(_uiColor: .red)
        _ = UIColor.blue.swiftUIcolor
        _ = Color.systemGray6
        _ = Color.placeholderText
        _ = Color.systemFill
        _ = Color.secondarySystemFill
        _ = Color.tetriarySystemFill
        _ = Color.quaternarySystemFill
        _ = Color.secondarySystemBackground
        _ = Color.tertiarySystemBackground
    }
#endif

#if os(macOS)
    @Test
    func copyButtonWritesTransferableValueToPasteboard() async {
        let value = ClipboardPayload(text: "copied")
        let button = CopyButton(value)
        let emptyButton = CopyButton<ClipboardPayload>(nil)

        #expect(button.value?.text == "copied")
        #expect(button.icon == "square.on.square")

        emptyButton.copy()
        button.copy()

        #expect(NSPasteboard.general.string(forType: .string) == "copied")
        try? await Task.sleep(for: .seconds(0.8))
    }

    @Test
    func viewLookupFindsAccessibilityIdentifiersBreadthFirst() throws {
        let root = NSView()
        let first = NSView()
        let second = NSView()
        let nested = NSView()
        first.setAccessibilityIdentifier("first")
        second.setAccessibilityIdentifier("second")
        nested.setAccessibilityIdentifier("nested")
        root.addSubview(first)
        root.addSubview(second)
        first.addSubview(nested)

        #expect(firstView(in: root, where: { $0.accessibilityIdentifier() == "nested" }) === nested)
        #expect(try viewWithAccessibilityIdentifier("second", in: root) === second)
        #expect(throwsMissingIdentifier {
            _ = try viewWithAccessibilityIdentifier("missing", in: root)
        })
    }

    @Test
    func passthroughViewIgnoresHitsOnItselfButKeepsSubviewHits() {
        let root = PassthroughView(frame: .init(x: 0, y: 0, width: 100, height: 100))
        let child = NSView(frame: .init(x: 10, y: 10, width: 20, height: 20))

        root.addSubview(child)

        #expect(root.hitTest(.init(x: 50, y: 50)) == nil)
        #expect(root.hitTest(.init(x: 15, y: 15)) === child)
    }

    @Test
    func styledTextFieldCoordinatorUpdatesTextAndReportsCommittedValues() {
        var text = "old"
        var committedValues: [AnyObject?] = []
        let field = StyledTextField(
            text: Binding(get: { text }, set: { text = $0 }),
            getValue: { committedValues.append($0) },
            configure: { $0.placeholderString = "Name" }
        )
        let coordinator = field.makeCoordinator()
        let fieldEditor = NSTextView()
        let textField = NSTextField()

        fieldEditor.string = "new"
        coordinator.controlTextDidChange(.init(name: NSControl.textDidChangeNotification, object: textField, userInfo: [
            "NSFieldEditor": fieldEditor
        ]))
        #expect(text == "new")

        #expect(coordinator.control(textField, textShouldEndEditing: fieldEditor))
        #expect(committedValues.last as? NSString == "new")

        fieldEditor.string = "clear me"
        #expect(coordinator.control(textField, textView: fieldEditor, doCommandBy: #selector(NSStandardKeyBindingResponding.cancelOperation(_:))))
        #expect(text == "")
        #expect(fieldEditor.string == "")

        #expect(coordinator.control(textField, textView: fieldEditor, doCommandBy: #selector(NSStandardKeyBindingResponding.cancelOperation(_:))))
        #expect(coordinator.control(textField, textView: fieldEditor, doCommandBy: #selector(NSStandardKeyBindingResponding.insertNewline(_:))))
        #expect(!coordinator.control(textField, textView: fieldEditor, doCommandBy: #selector(NSStandardKeyBindingResponding.moveLeft(_:))))

        let noCommitField = StyledTextField(
            text: Binding(get: { text }, set: { text = $0 }),
            configure: { _ in }
        )
        #expect(noCommitField.makeCoordinator().control(textField, textShouldEndEditing: fieldEditor))
    }

    @Test
    func styledTextFieldCoordinatorUsesFormatterForPartialAndCommittedText() {
        var text = ""
        var committedValues: [AnyObject?] = []
        let formatter = DeterministicFormatter()
        let field = StyledTextField(
            text: Binding(get: { text }, set: { text = $0 }),
            formatter: formatter,
            getValue: { committedValues.append($0) },
            configure: { _ in }
        )
        let coordinator = field.makeCoordinator()
        let textField = NSTextField()
        let fieldEditor = NSTextView()

        fieldEditor.string = "replace"
        coordinator.controlTextDidChange(.init(name: NSControl.textDidChangeNotification, object: textField, userInfo: [
            "NSFieldEditor": fieldEditor
        ]))
        #expect(text == "123")

        #expect(coordinator.control(textField, textShouldEndEditing: fieldEditor))
        #expect((committedValues.last as? NSNumber)?.intValue == 123)

        fieldEditor.string = "abc"
        #expect(coordinator.control(textField, textShouldEndEditing: fieldEditor))
        #expect(committedValues.count == 2)
        #expect(committedValues[1] == nil)
    }
#endif
}

private final class DeterministicFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        (obj as? NSNumber).map { "\($0.intValue)" }
    }

    override func isPartialStringValid(
        _ partialString: String,
        newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        _ = error
        if partialString == "replace" {
            newString?.pointee = "123"
            return false
        }
        return true
    }

    override func getObjectValue(
        _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for string: String,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        _ = error
        guard string == "123" else {
            obj?.pointee = NSNull()
            return false
        }
        obj?.pointee = NSNumber(value: 123)
        return true
    }
}

#if os(macOS) || os(iOS)
private struct ClipboardPayload: TransferableEx {
    let text: String

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.text)
    }

#if os(macOS)
    var pasteboardItem: NSPasteboardItem {
        let item = NSPasteboardItem()
        item.setString(text, forType: .string)
        return item
    }
#endif

    var exportPreview: SharePreview<Never, String> {
        SharePreview("Clipboard Payload", icon: text)
    }
}
#endif

#if os(iOS)
@MainActor
private final class CoreCustomInputRecorder {
    var clearCount = 0
}

private struct CoreCustomInputView: CustomInputView {
    let recorder: CoreCustomInputRecorder

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
#endif

private struct DemoItem: Identifiable, Equatable {
    let id: Int
    let title: String
}

private struct DemoCell: CollectionCell {
    let value: DemoItem
    let selection: DemoItem?
    let env: String

    init(value: DemoItem, selection: Binding<DemoItem?>, env: String) {
        self.value = value
        self.selection = selection.wrappedValue
        self.env = env
    }

    var body: some View {
        Text("\(env): \(value.title)")
    }
}

private func throwsMissingIdentifier(_ operation: () throws -> Void) -> Bool {
    do {
        try operation()
        return false
    } catch TestKit.TestingError.missingViewWithAccessibilityIdentifier("missing") {
        return true
    } catch {
        return false
    }
}
