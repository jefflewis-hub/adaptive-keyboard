import Foundation

enum CSVExporter {
    static func makeCSV(from records: [TapRecord]) -> String {
        var lines = ["target_char,tapped_char,is_hit,tap_x,tap_y,target_center_x,target_center_y,offset_x,offset_y,timestamp"]
        let formatter = ISO8601DateFormatter()
        for r in records {
            let target = r.targetChar == " " ? "SPACE" : String(r.targetChar)
            let tapped = r.tappedChar == " " ? "SPACE" : String(r.tappedChar)
            lines.append([
                target,
                tapped,
                r.isHit ? "1" : "0",
                String(format: "%.2f", r.tapPoint.x),
                String(format: "%.2f", r.tapPoint.y),
                String(format: "%.2f", r.targetKeyCenter.x),
                String(format: "%.2f", r.targetKeyCenter.y),
                String(format: "%.2f", r.offset.x),
                String(format: "%.2f", r.offset.y),
                formatter.string(from: r.timestamp),
            ].joined(separator: ","))
        }
        return lines.joined(separator: "\n")
    }

    /// Writes the CSV to a temp file and returns its URL, ready for ShareLink.
    static func writeTempFile(from records: [TapRecord]) -> URL? {
        let csv = makeCSV(from: records)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("tap-test-\(Int(Date().timeIntervalSince1970))")
            .appendingPathExtension("csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
}
