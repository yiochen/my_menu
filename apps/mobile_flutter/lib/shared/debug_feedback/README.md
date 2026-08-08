# Debug feedback

This folder is a self-contained, debug-only Flutter feedback collector. It has
no application-domain dependencies and can be copied into another Flutter
project.

Wrap the application content near the root:

```dart
final feedback = DebugFeedbackController();

DebugFeedbackOverlay(
  controller: feedback,
  child: appContent,
)
```

Call `feedback.startCollecting()` from a debug control. The user can tap a
meaningful widget, move between more-specific and broader candidates, and save
a comment. Call `feedback.buildAgentPrompt()` to produce the complete text to
paste into a coding agent.

The default classifier excludes layout and framework plumbing such as padding,
rows, columns, stacks, builders, and inherited wrappers. It recognizes
app-created components, controls, visible content, and useful semantics.

Important components can opt into a durable identifier:

```dart
FeedbackTarget(
  id: 'detail.primary_action',
  label: 'Primary action',
  child: PrimaryActionButton(),
)
```

Use `ExcludeFromFeedback` around debug UI or any subtree that should never be
selectable. Supply `persistEntries` to `DebugFeedbackController` if comments
should survive process restarts.

Automatic source locations rely on Flutter's widget-creation tracking, which
is enabled by default for debug runs. The framework remains usable without a
source location when a stable target ID or widget path is available.
