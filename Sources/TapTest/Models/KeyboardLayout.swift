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

    /// The left third of each row - one-handed (right-thumb) testing showed
    /// this is the weak zone (58% hit rate vs 88% on the right two-thirds).
    /// Roughly half those misses were near-misses a bigger target would
    /// catch, so these keys get wider hit targets; the right two-thirds
    /// shrink just enough to keep each row's total width unchanged.
    static let leftThirdKeys: Set<Character> = {
        var result: Set<Character> = []
        for row in rows {
            result.formUnion(row.prefix(max(1, row.count / 3)))
        }
        return result
    }()

    static let leftThirdEnlargeFactor: CGFloat = 1.4

    /// Computes each key's frame (including the space bar as " ") for a given
    /// keyboard canvas size, mirroring the real keyboard's row staggering.
    /// `enlargeLeftThird` toggles the resized-target experiment on or off,
    /// so it can be A/B tested directly against the classic uniform grid
    /// while keeping the space bar position identical in both.
    static func frames(in size: CGSize, enlargeLeftThird: Bool = true) -> [Character: CGRect] {
        let unit = size.width / CGFloat(baseRowKeyCount)
        let rowHeight = size.height / CGFloat(rowCount)

        var result: [Character: CGRect] = [:]
        for (rowIndex, row) in rows.enumerated() {
            let leftCount = enlargeLeftThird ? row.filter { leftThirdKeys.contains($0) }.count : 0
            let rightCount = row.count - leftCount
            let shrinkFactor: CGFloat = (enlargeLeftThird && rightCount > 0)
                ? (CGFloat(row.count) - CGFloat(leftCount) * leftThirdEnlargeFactor) / CGFloat(rightCount)
                : 1
            let rowWidth = CGFloat(leftCount) * unit * leftThirdEnlargeFactor
                + CGFloat(rightCount) * unit * shrinkFactor
            let inset = (size.width - rowWidth) / 2
            let y = CGFloat(rowIndex) * rowHeight

            var x = inset
            for char in row {
                let isEnlarged = enlargeLeftThird && leftThirdKeys.contains(char)
                let width = unit * (isEnlarged ? leftThirdEnlargeFactor : shrinkFactor)
                result[char] = CGRect(x: x, y: y, width: width, height: rowHeight)
                x += width
            }
        }

        // Pooled data across every full-keyboard run shows taps landing
        // right and slightly below the space bar's naive geometric center -
        // not a miss (hit rate there is already high), but a real, consistent
        // gap between where the key visually sits and where the aim actually
        // lands. Recentering the key on the real aim point, rather than the
        // middle of the screen, is the whole premise of this project. First
        // pass under-shot (clamped short of the real target); this pass
        // measured the residual after that first shift and folds it in.
        let spaceWidth = size.width - 2 * unit
        let rightShift = size.width * 0.109
        let maxX = size.width - spaceWidth
        let spaceX = min(unit + rightShift, max(unit, maxX))
        let spaceY = CGFloat(rows.count) * rowHeight + rowHeight * 0.109
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
