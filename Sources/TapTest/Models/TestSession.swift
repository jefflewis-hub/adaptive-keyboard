import CoreGraphics
import Foundation

enum TestStage {
    case intro
    case testing
    case results
}

enum TestMode: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case full = "Full"
    case sidesOnly = "Sides"
    case split = "Split"

    var id: String { rawValue }

    func makeSentences() -> [String] {
        switch self {
        case .classic, .full, .split: return Prompts.randomSet()
        case .sidesOnly: return Prompts.sideDrill()
        }
    }

    var keyboardStyle: KeyboardStyle {
        switch self {
        case .classic: return .gridClassic
        case .full, .sidesOnly: return .gridEnlargedLeft
        case .split: return .split
        }
    }
}

final class TestSession: ObservableObject {
    @Published var stage: TestStage = .intro
    @Published var mode: TestMode = .full
    @Published var sentenceIndex = 0
    @Published var charIndex = 0
    @Published var records: [TapRecord] = []
    @Published private(set) var sentences: [String] = TestMode.full.makeSentences()

    var currentSentenceChars: [Character] {
        Array(sentences[sentenceIndex])
    }

    var currentTargetChar: Character {
        currentSentenceChars[charIndex]
    }

    var totalChars: Int {
        sentences.reduce(0) { $0 + $1.count }
    }

    var completedChars: Int {
        sentences[..<sentenceIndex].reduce(0) { $0 + $1.count } + charIndex
    }

    var progress: Double {
        totalChars == 0 ? 0 : Double(completedChars) / Double(totalChars)
    }

    func start() {
        sentences = mode.makeSentences()
        stage = .testing
    }

    func recordTap(tappedChar: Character, tapPoint: CGPoint, targetKeyCenter: CGPoint) {
        let record = TapRecord(
            targetChar: currentTargetChar,
            tappedChar: tappedChar,
            tapPoint: tapPoint,
            targetKeyCenter: targetKeyCenter
        )
        records.append(record)
        advance()
    }

    private func advance() {
        if charIndex + 1 < currentSentenceChars.count {
            charIndex += 1
        } else if sentenceIndex + 1 < sentences.count {
            sentenceIndex += 1
            charIndex = 0
        } else {
            stage = .results
        }
    }

    func restart() {
        sentenceIndex = 0
        charIndex = 0
        records = []
        stage = .intro
    }
}
