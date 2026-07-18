import SwiftUI

/// A hand-drawn replica of the stock lowercase QWERTY keyboard. We can't read
/// raw touch coordinates off Apple's actual system keyboard from a normal
/// app, so this view stands in for it — close enough in proportions to be a
/// meaningful stand-in for where fingers land.
struct KeyboardView: View {
    let target: Character
    let style: KeyboardStyle
    let onTap: (_ tappedChar: Character, _ tapPoint: CGPoint, _ targetKeyCenter: CGPoint) -> Void

    // Guards against a single physical tap being recognized twice in a row
    // (observed during fast typing bursts with a zero-distance DragGesture,
    // which gets recreated on every render and can double-fire).
    @State private var lastTapTime: Date?
    @State private var lastTapPoint: CGPoint?

    var body: some View {
        GeometryReader { geo in
            let frames = style == .split
                ? SplitKeyboardLayout.frames(in: geo.size)
                : KeyboardLayout.frames(in: geo.size)

            ZStack(alignment: .topLeading) {
                ForEach(Array(frames.keys), id: \.self) { char in
                    if let frame = frames[char] {
                        KeyCap(char: char)
                            .frame(width: frame.width - 4, height: frame.height - 4)
                            .position(x: frame.midX, y: frame.midY)
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                SpatialTapGesture()
                    .onEnded { value in
                        let point = value.location
                        if isDuplicate(of: point) { return }
                        lastTapTime = Date()
                        lastTapPoint = point

                        let tapped = KeyboardLayout.nearestKey(to: point, in: frames)
                        let targetCenter = frames[target]?.center ?? point
                        onTap(tapped, point, targetCenter)
                    }
            )
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
    case grid
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
