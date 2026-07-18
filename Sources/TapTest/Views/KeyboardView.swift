import SwiftUI

/// A hand-drawn replica of the stock lowercase QWERTY keyboard. We can't read
/// raw touch coordinates off Apple's actual system keyboard from a normal
/// app, so this view stands in for it — close enough in proportions to be a
/// meaningful stand-in for where fingers land.
struct KeyboardView: View {
    @ObservedObject var session: TestSession
    let style: KeyboardStyle

    // Defense-in-depth against a single physical tap being recorded twice at
    // nearly the same point in quick succession.
    @State private var lastTapTime: Date?
    @State private var lastTapPoint: CGPoint?

    var body: some View {
        GeometryReader { geo in
            let frames: [Character: CGRect]
            switch style {
            case .split:
                frames = SplitKeyboardLayout.frames(in: geo.size)
            case .gridEnlargedLeft:
                frames = KeyboardLayout.frames(in: geo.size, enlargeLeftThird: true)
            case .gridClassic:
                frames = KeyboardLayout.frames(in: geo.size, enlargeLeftThird: false)
            }

            ZStack(alignment: .topLeading) {
                ForEach(Array(frames.keys), id: \.self) { char in
                    if let frame = frames[char] {
                        KeyCap(char: char)
                            .frame(width: frame.width - 4, height: frame.height - 4)
                            .position(x: frame.midX, y: frame.midY)
                    }
                }

                // `session` is read here, not captured from whatever `target`
                // value was current when this closure was created - under
                // fast typing, SwiftUI can be a render or two behind by the
                // time this fires, so a captured snapshot would score the
                // tap against a stale target. Reading `session` live at the
                // moment the touch actually happens is always correct.
                TouchCaptureView { point in
                    if isDuplicate(of: point) { return }
                    lastTapTime = Date()
                    lastTapPoint = point

                    let tapped = KeyboardLayout.nearestKey(to: point, in: frames)
                    let target = session.currentTargetChar
                    let targetCenter = frames[target]?.center ?? point
                    session.recordTap(tappedChar: tapped, tapPoint: point, targetKeyCenter: targetCenter)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .frame(height: style == .split ? 320 : 220)
        .background(Color(.systemGray5))
    }

    private func isDuplicate(of point: CGPoint) -> Bool {
        guard let lastTapTime, let lastTapPoint else { return false }
        let sameSpot = abs(point.x - lastTapPoint.x) < 2 && abs(point.y - lastTapPoint.y) < 2
        return sameSpot && Date().timeIntervalSince(lastTapTime) < 0.15
    }
}

enum KeyboardStyle {
    case gridClassic
    case gridEnlargedLeft
    case split
}

private struct KeyCap: View {
    let char: Character

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(.systemGray3), lineWidth: 1)
            )
            .overlay(
                Text(char == " " ? "space" : String(char))
                    .font(.system(size: char == " " ? 14 : 20, weight: .medium))
                    .foregroundColor(.primary)
            )
            .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
    }
}
