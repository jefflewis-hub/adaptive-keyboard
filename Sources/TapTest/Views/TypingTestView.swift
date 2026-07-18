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
        return chars.indices.reduce(Text("")) { partial, i in
            let char = chars[i]
            let display = char == " " ? " " : String(char)
            var segment = Text(display)
            if i < session.charIndex {
                segment = segment.foregroundColor(.secondary)
            } else if i == session.charIndex {
                segment = segment.foregroundColor(.accentColor).bold()
                    .font(.system(.title2, design: .monospaced))
            } else {
                segment = segment.foregroundColor(.primary.opacity(0.35))
            }
            return partial + segment
        }
        .font(.system(.title2, design: .monospaced))
        .lineSpacing(6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
