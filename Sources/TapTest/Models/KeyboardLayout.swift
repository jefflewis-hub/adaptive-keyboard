import CoreGraphics

/// A simplified replica of the stock iPhone lowercase QWERTY layout: three
/// staggered letter rows plus a space bar. No shift/delete/return — the test
/// sentences are lowercase-only and forced-advance, so those keys aren't needed.
enum KeyboardLayout {
    static let rows: [[Character]] = [
        Array("qwertyuiop"),
        Array("asdfghjkl"),
        Array("zxcvbnm"),
    ]

    static let rowCount = rows.count + 1 // + space bar row
    static let baseRowKeyCount = 10 // row 1 defines the key unit width

    /// Keys near the left/right edges of each row - closest to a thumb's
    /// natural pivot point, farthest from the awkward middle reach.
    static let sideKeys: Set<Character> = {
        var result: Set<Character> = []
        for row in rows {
            let edgeCount = max(1, row.count / 3)
            result.formUnion(row.prefix(edgeCount))
            result.formUnion(row.suffix(edgeCount))
        }
        return result
    }()

    /// Computes each key's frame (including the space bar as " ") for a given
    /// keyboard canvas size, mirroring the real keyboard's row staggering.
    static func frames(in size: CGSize) -> [Character: CGRect] {
        let unit = size.width / CGFloat(baseRowKeyCount)
        let rowHeight = size.height / CGFloat(rowCount)

        var result: [Character: CGRect] = [:]
        for (rowIndex, row) in rows.enumerated() {
            let rowWidth = CGFloat(row.count) * unit
            let inset = (size.width - rowWidth) / 2
            let y = CGFloat(rowIndex) * rowHeight
            for (i, char) in row.enumerated() {
                let x = inset + CGFloat(i) * unit
                result[char] = CGRect(x: x, y: y, width: unit, height: rowHeight)
            }
        }

        // Pooled data across every full-keyboard run so far shows a taps
        // land ~11-12% of the keyboard's width to the right of the space
        // bar's naive geometric center - not a miss (hit rate there is
        // already high), but a real, consistent gap between where the key
        // visually sits and where the aim actually lands. Recentering the
        // key on the real aim point, rather than the middle of the screen,
        // is the whole premise of this project.
        let spaceY = CGFloat(rows.count) * rowHeight
        let spaceWidth = size.width - 2 * unit
        let rightShift = size.width * 0.116
        let maxX = size.width - unit * 0.5 - spaceWidth
        let spaceX = min(unit + rightShift, max(unit, maxX))
        result[" "] = CGRect(x: spaceX, y: spaceY, width: spaceWidth, height: rowHeight)

        return result
    }

    static func nearestKey(to point: CGPoint, in frames: [Character: CGRect]) -> Character {
        if let contained = frames.first(where: { $0.value.contains(point) }) {
            return contained.key
        }
        return frames.min { lhs, rhs in
            distanceSquared(point, lhs.value.center) < distanceSquared(point, rhs.value.center)
        }?.key ?? " "
    }

    private static func distanceSquared(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return dx * dx + dy * dy
    }
}

extension CGRect {
    var center: CGPoint { CGPoint(x: midX, y: midY) }
}
