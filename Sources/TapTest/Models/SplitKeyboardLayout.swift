import CoreGraphics

/// A two-cluster layout: no keys in the middle ~28% of the width at all,
/// and each side cluster is taller (more rows) than the flat 3-row grid,
/// since removing the middle frees up width to redistribute into height.
/// Letters are split using the standard left-hand/right-hand touch-typing
/// assignment, so all 26 letters + space still map to exactly one slot.
enum SplitKeyboardLayout {
    static let leftGrid: [[Character]] = [
        Array("qwer"),
        Array("tasd"),
        Array("fgzx"),
        Array("cvb "),
    ]

    static let rightGrid: [[Character]] = [
        Array("yuio"),
        Array("phjk"),
        Array("lnm"),
    ]

    static let middleGapFraction: CGFloat = 0.28
    static let sideFraction: CGFloat = (1 - middleGapFraction) / 2

    static func frames(in size: CGSize) -> [Character: CGRect] {
        var result: [Character: CGRect] = [:]
        let sideWidth = size.width * sideFraction
        addGrid(leftGrid, xStart: 0, width: sideWidth, in: size, into: &result)
        let rightXStart = size.width * (sideFraction + middleGapFraction)
        addGrid(rightGrid, xStart: rightXStart, width: sideWidth, in: size, into: &result)
        return result
    }

    private static func addGrid(
        _ grid: [[Character]], xStart: CGFloat, width: CGFloat, in size: CGSize,
        into result: inout [Character: CGRect]
    ) {
        let rowHeight = size.height / CGFloat(grid.count)
        for (rowIndex, row) in grid.enumerated() {
            let colWidth = width / CGFloat(row.count)
            let y = CGFloat(rowIndex) * rowHeight
            for (colIndex, char) in row.enumerated() {
                let x = xStart + CGFloat(colIndex) * colWidth
                result[char] = CGRect(x: x, y: y, width: colWidth, height: rowHeight)
            }
        }
    }
}
