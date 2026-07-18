import SwiftUI

struct IntroView: View {
    @ObservedObject var session: TestSession

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Tap Test")
                .font(.largeTitle.bold())

            Text("You'll type out a few sentences on the keyboard below. Just tap normally, at your natural pace — don't try to be careful. Every tap gets recorded, right or wrong, and we move on to the next letter regardless.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)

            Text("\(session.sentences.count) sentences · \(session.totalChars) taps total")
                .font(.footnote)
                .foregroundColor(.secondary)

            Spacer()

            Button {
                session.start()
            } label: {
                Text("Start")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}
