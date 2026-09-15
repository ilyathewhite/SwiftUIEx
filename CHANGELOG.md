# Changelog

## 1.1.0

- Require Swift 6.0 or later and build both library targets and tests in Swift 6 language mode.
- Require FoundationEx 1.1.0 and remove the unused CombineEx dependency.
- Isolate UI helpers, animation state, and export requirements to the main actor.
- Let `CopyButton` use a custom `TransferableEx.itemProvider` on iOS, with a default
  implementation that preserves the existing Transferable-based provider behavior.
- Cover custom clipboard providers with an iOS regression test.

### Migration

UI helpers and `TransferableEx` export requirements must be used on the main actor.
Custom item providers can prepare export data before publishing it to the clipboard,
so provider callbacks do not need to wait for main-actor rendering. Deployment targets
are unchanged.
