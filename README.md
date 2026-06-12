# SpaceFollowKit

`SpaceFollowKit` makes macOS subwindows follow Spaces with correct z-order and no swipe-time "always on top" glitch.

## Features

- `SubwindowSpacesBehavior` to apply Space-aware collection behavior.
- `SubwindowSpaceHandoffCoordinator` for deterministic close/reopen handoff on Space change.
- Configurable AppStorage key and handoff timing.

## Requirements

- macOS 14+
- Swift 5.10+

## Installation (SPM)

```swift
dependencies: [
    .package(url: "https://github.com/tjcages/space-follow-kit.git", from: "0.1.0")
]
```

Then add the product:

```swift
.product(name: "SpaceFollowKit", package: "space-follow-kit")
```

## Basic Usage

```swift
import SpaceFollowKit

Window("Quick Capture", id: "quick-capture") {
    QuickCaptureView()
        .subwindowSpacesBehavior(storageKey: "subwindowsOnAllSpaces")
}
```

```swift
import SwiftUI
import SpaceFollowKit

struct GroupWindowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openWindow) private var openWindow
    @AppStorage("subwindowsOnAllSpaces") private var onAllSpaces = false

    @State private var hostWindow: NSWindow?
    @StateObject private var handoff = SubwindowSpaceHandoffCoordinator()
    let selection: SidebarItem

    var body: some View {
        content
            .background(WindowAccessor { window in
                hostWindow = window
                handoff.markAttached()
            })
            .onReceive(NSWorkspace.shared.notificationCenter.publisher(
                for: NSWorkspace.activeSpaceDidChangeNotification
            )) { _ in
                handoff.handoffIfNeeded(
                    enabled: onAllSpaces,
                    window: hostWindow,
                    persistFrame: { saveFrame(hostWindow) },
                    dismissCurrent: { dismiss() },
                    reopen: { openWindow(value: selection) }
                )
            }
    }
}
```
