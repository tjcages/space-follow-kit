import SwiftUI
import AppKit

/// Reusable API for macOS sub-window Spaces behavior.
@MainActor
public final class SubwindowSpaceHandoffCoordinator: ObservableObject {
    private var pending = false
    private let reopenDelay: TimeInterval
    private let pendingResetDelay: TimeInterval

    /// - Parameters:
    ///   - reopenDelay: Delay between dismissing the source window and reopening
    ///     on the active Space. Defaults to `0.35`.
    ///   - pendingResetDelay: Fallback reset in case `markAttached()` is never
    ///     called (for example, reopen failed). Defaults to `1.0`.
    public init(reopenDelay: TimeInterval = 0.35, pendingResetDelay: TimeInterval = 1.0) {
        self.reopenDelay = reopenDelay
        self.pendingResetDelay = pendingResetDelay
    }

    public func markAttached() {
        pending = false
    }

    public func handoffIfNeeded(
        enabled: Bool,
        window: NSWindow?,
        persistFrame: () -> Void,
        dismissCurrent: @escaping () -> Void,
        reopen: @escaping () -> Void
    ) {
        guard enabled, !pending, let window, window.isVisible else { return }
        pending = true
        persistFrame()
        dismissCurrent()
        DispatchQueue.main.asyncAfter(deadline: .now() + reopenDelay) { [weak self] in
            reopen()
            // Safety valve in case attach never comes back.
            let resetDelay = self?.pendingResetDelay ?? 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) { [weak self] in
                self?.pending = false
            }
        }
    }
}

public struct SubwindowSpacesBehavior: ViewModifier {
    @AppStorage("subwindowsOnAllSpaces") private var onAllSpaces = false

    /// - Parameters:
    ///   - storageKey: UserDefaults key for the on/off toggle.
    ///   - store: Optional custom defaults store.
    public init(
        storageKey: String = "subwindowsOnAllSpaces",
        store: UserDefaults? = nil
    ) {
        _onAllSpaces = AppStorage(wrappedValue: false, storageKey, store: store)
    }

    public func body(content: Content) -> some View {
        content.background(SubwindowSpacesConfigurator(onAllSpaces: onAllSpaces))
    }
}

private struct SubwindowSpacesConfigurator: NSViewRepresentable {
    let onAllSpaces: Bool

    func makeNSView(context: Context) -> ConfiguratorView {
        let view = ConfiguratorView()
        view.onAllSpaces = onAllSpaces
        return view
    }

    func updateNSView(_ view: ConfiguratorView, context: Context) {
        view.onAllSpaces = onAllSpaces
        view.apply()
    }

    final class ConfiguratorView: NSView {
        var onAllSpaces = false

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            apply()
        }

        func apply() {
            guard let window else { return }
            SubwindowSpacesBehavior.applyCollectionBehavior(onAllSpaces: onAllSpaces, to: window)
        }
    }
}

public extension SubwindowSpacesBehavior {
    static func applyCollectionBehavior(onAllSpaces: Bool, to window: NSWindow) {
        // Spaces group — at most one of {default, canJoinAllSpaces, moveToActiveSpace}.
        window.collectionBehavior.subtract([.canJoinAllSpaces, .moveToActiveSpace])
        if onAllSpaces {
            // Avoid canJoinAllSpaces compositor lift during swipe transitions.
            window.collectionBehavior.insert(.moveToActiveSpace)
        }

        // Keep normal Mission Control behavior for the window's level.
        window.collectionBehavior.subtract(.stationary)
        if window.level == .normal {
            window.collectionBehavior.subtract(.transient)
            window.collectionBehavior.insert(.managed)
        } else {
            window.collectionBehavior.subtract(.managed)
            window.collectionBehavior.insert(.transient)
        }
    }
}

public extension View {
    /// Apply sub-window Spaces behavior driven by an AppStorage boolean.
    func subwindowSpacesBehavior(
        storageKey: String = "subwindowsOnAllSpaces",
        store: UserDefaults? = nil
    ) -> some View {
        modifier(SubwindowSpacesBehavior(storageKey: storageKey, store: store))
    }
}
