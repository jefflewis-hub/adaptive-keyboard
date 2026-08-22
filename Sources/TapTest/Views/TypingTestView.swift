import SwiftUI

struct TypingTestView: View {
    @ObservedObject var session: TestSession

    var body: some View {
        VStack(spacing: 0) {
            ProgressView(value: session.progress)
                .padding(.horizontal)
                .padding(.top, 12)

            Text("Sentence \(session.sentenceIndex + 1) of \(session.sentences.count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)

            Spacer()

            sentenceText
                .padding(.horizontal, 24)

            Spacer()

            KeyboardView(session: session, style: session.mode.keyboardStyle)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var sentenceText: some View {
        let chars = session.currentSentenceChars
        var attributed = AttributedString(String(chars))
        attributed.font = .system(.title2, design: .monospaced)
        for i in chars.indices {
            guard let start = attributed.characters.index(attributed.startIndex, offsetBy: i, limitedBy: attributed.endIndex),
                  let end = attributed.characters.index(start, offsetBy: 1, limitedBy: attributed.endIndex) else { continue }
            let range = start..<end
            if i < session.charIndex {
                attributed[range].foregroundColor = .secondary
            } else if i == session.charIndex {
                attributed[range].foregroundColor = .accentColor
                attributed[range].font = .system(.title2, design: .monospaced).bold()
            } else {
                attributed[range].foregroundColor = .primary.opacity(0.35)
            }
        }
        return Text(attributed)
            .lineSpacing(6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
    }
}
