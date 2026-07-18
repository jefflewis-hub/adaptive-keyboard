# Adaptive Keyboard — Tap Test (Phase 1)

Before building a keyboard that changes key shape/position per user, this
phase-1 app answers the question: **how consistent are one person's misses,
really?**

It's a small SwiftUI iPhone app with its own hand-drawn QWERTY keyboard. You
type out a handful of pangram sentences at your normal pace; every tap is
logged as a raw `(x, y)` point along with which key you were aiming for and
which key the app decided you actually hit. At the end you get a scatter
chart of the offsets, per-key stats (bias direction, spread, hit rate), and
a CSV export.

This is **not** a system keyboard extension (no "Full Access" needed, no
installing a new keyboard in Settings) — it's a normal app with its own
on-screen keyboard, which is enough to measure raw tap accuracy.

## Important: run this on a real iPhone, not the Simulator

The whole point is measuring finger-tap imprecision. Simulator taps come
from your mouse/trackpad and are pixel-perfect, which would defeat the
purpose. Plug in an iPhone and run on it directly.

## Build & run

1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) if you don't
   have it:
   ```
   brew install xcodegen
   ```
2. From this directory, generate the Xcode project:
   ```
   xcodegen generate
   ```
3. Open `AdaptiveKeyboard.xcodeproj` in Xcode.
4. Select your iPhone as the run destination (plug it in, trust the
   computer if prompted).
5. In the project settings, under **Signing & Capabilities** for the
   `TapTest` target, set your Team to your personal Apple ID (free account
   is fine for local testing — "Automatically manage signing" is already
   on).
6. Run (⌘R). You may need to go to **Settings → General → VPN & Device
   Management** on the phone the first time to trust the developer
   certificate.

## Using it

- Tap **Start**, then just type the sentences shown at the top, tapping
  wherever you'd naturally tap. Every tap is recorded and it always
  advances to the next letter — there's no "try again," so don't worry
  about getting it right.
- When all sentences are done, you'll see the results screen:
  - A scatter chart of every tap's offset from the true center of the key
    you were aiming for (0,0 = dead center). Filter by key using the chip
    row above the chart.
  - A table of per-key stats: sample count, mean horizontal/vertical bias,
    hit rate.
  - **Export CSV** to share the raw data (via the share sheet — AirDrop,
    Files, Messages, etc.) for deeper analysis.

## What this data is for

This is the raw material for phase 2: fitting each key a personalized
offset + spread (essentially a small 2D distribution), which is what would
eventually drive both the invisible tap-target adjustment and — per what
we discussed — the actual visible key repositioning/resizing in a real
custom keyboard extension. That's a separate, larger project; this app is
just to see how "crazy" and how consistent the miss patterns actually are
before committing to it.

## Project layout

```
Sources/TapTest/
  TapTestApp.swift        entry point
  RootView.swift           intro -> testing -> results flow
  Models/
    TapRecord.swift        one recorded tap
    KeyboardLayout.swift    key geometry (frames from a canvas size)
    Prompts.swift           pangram test sentences
    TestSession.swift       test progress + recorded taps
  Views/
    IntroView.swift
    TypingTestView.swift    sentence progress + hosts KeyboardView
    KeyboardView.swift      the custom keyboard + tap capture
    ResultsView.swift       scatter chart, stats table, CSV export
  Utilities/
    KeyStats.swift          per-key mean/stddev/hit-rate
    CSVExporter.swift
```
