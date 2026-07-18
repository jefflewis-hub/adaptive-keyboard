import CoreGraphics
import Foundation

struct KeyStats: Identifiable {
    let key: Character
    let sampleCount: Int
    let meanOffset: CGPoint
    let stdDevX: Double
    let stdDevY: Double
    let hitRate: Double

    var id: Character { key }

    static func compute(from records: [TapRecord]) -> [KeyStats] {
        let grouped = Dictionary(grouping: records, by: { $0.targetChar })
        return grouped.map { key, recs in
            let n = Double(recs.count)
            let meanX = recs.reduce(0.0) { $0 + $1.offset.x } / n
            let meanY = recs.reduce(0.0) { $0 + $1.offset.y } / n
            let varX = recs.reduce(0.0) { $0 + pow($1.offset.x - meanX, 2) } / n
            let varY = recs.reduce(0.0) { $0 + pow($1.offset.y - meanY, 2) } / n
            let hits = recs.filter(\.isHit).count
            return KeyStats(
                key: key,
                sampleCount: recs.count,
                meanOffset: CGPoint(x: meanX, y: meanY),
                stdDevX: sqrt(varX),
                stdDevY: sqrt(varY),
                hitRate: Double(hits) / n
            )
        }.sorted { $0.key < $1.key }
    }
}
