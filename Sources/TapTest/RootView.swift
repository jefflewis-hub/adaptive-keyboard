import SwiftUI

struct RootView: View {
    @StateObject private var session = TestSession()

    var body: some View {
        switch session.stage {
        case .intro:
            IntroView(session: session)
        case .testing:
            TypingTestView(session: session)
        case .results:
            ResultsView(session: session)
        }
    }
}
