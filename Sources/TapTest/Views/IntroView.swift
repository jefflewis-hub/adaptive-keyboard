import SwiftUI

struct IntroView: View {
    @ObservedObject var session: TestSession

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Tap Test")
                .font(.largeTitle.bold())

            Picker("Mode", selection: $session.mode) {
                ForEach(TestMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 32)

            Text(descriptionText)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)

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

    private var descriptionText: String {
        switch session.mode {
        case .full:
            return "You'll type out a few sentences on the keyboard below. Just tap normally, at your natural pace — don't try to be careful. Every tap gets recorded, right or wrong, and we move on to the next letter regardless."
        case .sidesOnly:
            return "This drill only asks for letters near the left/right edges of the keyboard — no middle-cluster letters, no space bar. Just tap normally at your natural pace; it's random letters, not real words, so don't try to read meaning into it."
        }
    }
}
