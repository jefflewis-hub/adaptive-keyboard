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

        let spaceY = CGFloat(rows.count) * rowHeight
        result[" "] = CGRect(x: unit, y: spaceY, width: size.width - 2 * unit, height: rowHeight)

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
