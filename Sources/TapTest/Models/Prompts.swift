enum Prompts {
    /// Pangrams, lowercased and stripped of punctuation so every target
    /// character maps directly to a key on the simplified layout (letters
    /// + space only). A larger pool than any single run needs, so a fresh
    /// random subset can be picked each time - typing the exact same
    /// sequence repeatedly lets you start anticipating letters instead of
    /// reacting to them, which would skew the data the same way the old
    /// key-highlight did.
    static let pool: [String] = [
        "the quick brown fox jumps over the lazy dog",
        "pack my box with five dozen liquor jugs",
        "how vexingly quick daft zebras jump",
        "sphinx of black quartz judge my vow",
        "the five boxing wizards jump quickly",
        "jived fox nymph grabs quick waltz",
        "waltz bad nymph for quick jigs vex",
        "quick zephyrs blow vexing daft jim",
        "two driven jocks help fax my big quiz",
        "five quacking zephyrs jolt my wax bed",
        "a wizards job is to vex chumps quickly in fog",
        "we promptly judged antique ivory buckles for the next prize",
        "crazy fredrick bought many very exquisite opal jewels",
        "amazingly few discotheques provide jukeboxes",
    ]

    /// A fresh, shuffled subset for one test run.
    static func randomSet(count: Int = 7) -> [String] {
        Array(pool.shuffled().prefix(count))
    }
}
