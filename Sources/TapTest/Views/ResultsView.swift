import Charts
import SwiftUI

struct ResultsView: View {
    @ObservedObject var session: TestSession
    @State private var selectedKey: Character? = nil
    @State private var exportURL: URL?

    private var stats: [KeyStats] { KeyStats.compute(from: session.records) }

    private var filteredRecords: [TapRecord] {
        guard let selectedKey else { return session.records }
        return session.records.filter { $0.targetChar == selectedKey }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                keyPicker

                chart
                    .frame(height: 320)
                    .padding(.horizontal)

                statsTable

                HStack(spacing: 12) {
                    exportButton
                    Button("Retry") { session.restart() }
                        .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .padding(.top, 16)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Results")
                .font(.largeTitle.bold())
            Text("\(session.records.count) taps · overall hit rate \(overallHitRatePercent)%")
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }

    private var overallHitRatePercent: String {
        guard !session.records.isEmpty else { return "0" }
        let hits = session.records.filter(\.isHit).count
        return String(format: "%.0f", 100.0 * Double(hits) / Double(session.records.count))
    }

    private var keyPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(label: "All", isSelected: selectedKey == nil) { selectedKey = nil }
                ForEach(stats) { stat in
                    chip(label: stat.key == " " ? "␣" : String(stat.key), isSelected: selectedKey == stat.key) {
                        selectedKey = stat.key
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func chip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }

    private var chart: some View {
        Chart {
            ForEach(filteredRecords) { record in
                PointMark(
                    x: .value("dx", Double(record.offset.x)),
                    y: .value("dy", Double(record.offset.y))
                )
                .foregroundStyle(by: .value("Key", String(record.targetChar == " " ? "␣" : record.targetChar)))
                .opacity(0.6)
            }
            RuleMark(x: .value("center", 0.0))
                .foregroundStyle(.gray.opacity(0.5))
            RuleMark(y: .value("center", 0.0))
                .foregroundStyle(.gray.opacity(0.5))
        }
        .chartXAxisLabel("horizontal offset (pt) — right of key center →")
        .chartYAxisLabel("vertical offset (pt) — below key center ↓")
        .chartLegend(selectedKey == nil ? .visible : .hidden)
    }

    private var statsTable: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("key").frame(width: 40, alignment: .leading)
                Text("n").frame(width: 40, alignment: .trailing)
                Text("mean dx").frame(width: 70, alignment: .trailing)
                Text("mean dy").frame(width: 70, alignment: .trailing)
                Text("hit%").frame(width: 50, alignment: .trailing)
            }
            .font(.caption.bold())
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.bottom, 4)

            ForEach(stats) { stat in
                HStack {
                    Text(stat.key == " " ? "␣" : String(stat.key)).frame(width: 40, alignment: .leading)
                    Text("\(stat.sampleCount)").frame(width: 40, alignment: .trailing)
                    Text(String(format: "%.1f", stat.meanOffset.x)).frame(width: 70, alignment: .trailing)
                    Text(String(format: "%.1f", stat.meanOffset.y)).frame(width: 70, alignment: .trailing)
                    Text(String(format: "%.0f", stat.hitRate * 100)).frame(width: 50, alignment: .trailing)
                }
                .font(.system(.footnote, design: .monospaced))
                .padding(.horizontal)
                .padding(.vertical, 2)
            }
        }
    }

    @ViewBuilder
    private var exportButton: some View {
        if let url = exportURL {
            ShareLink(item: url) {
                Label("Export CSV", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
        } else {
            Button {
                exportURL = CSVExporter.writeTempFile(from: session.records)
            } label: {
                Label("Prepare CSV", systemImage: "doc.badge.plus")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
