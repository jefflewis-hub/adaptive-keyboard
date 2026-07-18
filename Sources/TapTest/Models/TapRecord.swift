import CoreGraphics
import Foundation

struct TapRecord: Identifiable, Codable {
    let id: UUID
    let targetChar: Character
    let tappedChar: Character
    let tapPoint: CGPoint
    let targetKeyCenter: CGPoint
    let timestamp: Date

    init(targetChar: Character, tappedChar: Character, tapPoint: CGPoint, targetKeyCenter: CGPoint) {
        self.id = UUID()
        self.targetChar = targetChar
        self.tappedChar = tappedChar
        self.tapPoint = tapPoint
        self.targetKeyCenter = targetKeyCenter
        self.timestamp = Date()
    }

    /// Offset of the raw tap from the true center of the intended key, in points.
    /// Positive dx = tapped right of center, positive dy = tapped below center.
    var offset: CGPoint {
        CGPoint(x: tapPoint.x - targetKeyCenter.x, y: tapPoint.y - targetKeyCenter.y)
    }

    var isHit: Bool { tappedChar == targetChar }
}

// Character isn't Codable by default; encode/decode as a single-character String.
extension TapRecord {
    private enum CodingKeys: String, CodingKey {
        case id, targetChar, tappedChar, tapPoint, targetKeyCenter, timestamp
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        targetChar = Character(try c.decode(String.self, forKey: .targetChar))
        tappedChar = Character(try c.decode(String.self, forKey: .tappedChar))
        tapPoint = try c.decode(CGPoint.self, forKey: .tapPoint)
        targetKeyCenter = try c.decode(CGPoint.self, forKey: .targetKeyCenter)
        timestamp = try c.decode(Date.self, forKey: .timestamp)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(String(targetChar), forKey: .targetChar)
        try c.encode(String(tappedChar), forKey: .tappedChar)
        try c.encode(tapPoint, forKey: .tapPoint)
        try c.encode(targetKeyCenter, forKey: .targetKeyCenter)
        try c.encode(timestamp, forKey: .timestamp)
    }
}
