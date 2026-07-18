enum Prompts {
    /// Classic pangrams, lowercased and stripped of punctuation so every
    /// target character maps directly to a key on the simplified layout
    /// (letters + space only).
    static let sentences: [String] = [
        "the quick brown fox jumps over the lazy dog",
        "pack my box with five dozen liquor jugs",
        "how vexingly quick daft zebras jump",
        "sphinx of black quartz judge my vow",
        "the five boxing wizards jump quickly",
        "jived fox nymph grabs quick waltz",
        "waltz bad nymph for quick jigs vex",
    ]
}
