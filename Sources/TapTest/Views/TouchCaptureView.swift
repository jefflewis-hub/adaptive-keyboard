import SwiftUI
import UIKit

/// Captures raw touch-down location via a persistent native UIView instead
/// of a SwiftUI `.gesture()`. SwiftUI recreates gesture recognizers on every
/// render of the view they're attached to, and this view's parent re-renders
/// on every single tap (its target/frames change) - under fast typing, a
/// stale recognizer from a prior render could fire its completion late,
/// after a newer tap had already advanced the test, corrupting which target
/// a tap gets scored against. A plain UIView's touchesBegan doesn't have
/// that recreation problem: makeUIView runs once for the view's lifetime,
/// and only the callback closure gets refreshed each render.
struct TouchCaptureView: UIViewRepresentable {
    var onTouch: (CGPoint) -> Void

    func makeUIView(context: Context) -> TouchView {
        let view = TouchView()
        view.onTouch = { point in context.coordinator.onTouch(point) }
        return view
    }

    func updateUIView(_ uiView: TouchView, context: Context) {
        context.coordinator.onTouch = onTouch
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTouch: onTouch)
    }

    final class Coordinator {
        var onTouch: (CGPoint) -> Void
        init(onTouch: @escaping (CGPoint) -> Void) {
            self.onTouch = onTouch
        }
    }

    final class TouchView: UIView {
        var onTouch: ((CGPoint) -> Void)?

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            onTouch?(touch.location(in: self))
        }
    }
}
