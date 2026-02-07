# SwiftfulSoundEffects

Actor-based sound effect library. Manages AVAudioPlayers with round-robin selection for simultaneous playback. iOS and macOS.

## API

- `SoundEffectManager` is an `actor` but all public methods are `nonisolated` — no `await` needed
- `prepareSoundEffect(url:simultaneousPlayers:volume:)` creates players for a sound — required before play
- `playSoundEffect(url:)` plays the next available player via round-robin
- `tearDownSoundEffect(url:)` stops and removes all players for a sound

```swift
let soundEffectManager = SoundEffectManager()

// Optional logger for analytics
let soundEffectManager = SoundEffectManager(logger: yourLogger)
```

### Prepare

```swift
// Single player (default) — play() restarts if already playing
soundEffectManager.prepareSoundEffect(url: url)

// Multiple players — supports overlapping playback
soundEffectManager.prepareSoundEffect(url: url, simultaneousPlayers: 6)

// Custom volume (0.0 to 1.0)
soundEffectManager.prepareSoundEffect(url: url, simultaneousPlayers: 1, volume: 0.5)
```

### Play

```swift
soundEffectManager.playSoundEffect(url: url)
```

### Tear Down

```swift
// Remove all players for a specific sound
soundEffectManager.tearDownSoundEffect(url: url)
```

## Sound Effect Files

Sound files are NOT included in the package. The consuming project must add audio files (`.wav`, `.mp3`, etc.) to its own bundle.

Use a `SoundEffectFile` enum to manage file names and URLs. This is the preferred pattern:

```swift
enum SoundEffectFile: String, Equatable {
    case coin
    case pop
    case success

    var fileName: String {
        switch self {
        case .coin: return "Coin.wav"
        case .pop: return "Pop.wav"
        case .success: return "Success.wav"
        }
    }

    var url: URL {
        let path = Bundle.main.path(forResource: fileName, ofType: nil)!
        return URL(fileURLWithPath: path)
    }
}
```

When adding new sound effects, add a case to this enum rather than hardcoding file names or URLs throughout the project.

## Integration

Conform your logger to `SoundEffectLogger` to receive internal events:

```swift
extension YourLogManager: @retroactive SoundEffectLogger {
    public func trackEvent(event: any SoundEffectLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type)
    }
    public func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        // forward to your analytics
    }
}
```

## Sound Effect Selection Guide

IMPORTANT: Use sound effects sparingly. Only add sounds to meaningful interactions — not every tap or swipe.

### When to use sound effects

- **Purchase completed / payment success** — audible confirmation
- **Achievement unlocked / level up** — celebratory feedback
- **Error or failure** — audible alert for important failures
- **Game actions** — coin collect, power-up, hit effects

### When NOT to use sound effects

- NEVER add sounds to every button tap or navigation
- NEVER fire sounds on continuous events (scrolling, dragging, typing)
- NEVER play sounds without user expectation — respect the user's audio environment
- A screen should typically have 0-2 sound touch points

### Simultaneous players guide

- **1 player (default):** Good for most sounds — play restarts if still playing
- **2-4 players:** Sounds that may overlap occasionally (button feedback in rapid UI)
- **4-8 players:** Rapid-fire sounds (coin collection, typing effects)

## Lifecycle

Prepare sound effects on screen appear. Tear down is optional — only needed to explicitly free resources.

```swift
.onAppear {
    soundEffectManager.prepareSoundEffect(url: SoundEffectFile.coin.url, simultaneousPlayers: 4)
}
```

### VIPER Integration

In a VIPER architecture, sound effects flow through three layers:

```swift
// View — triggers presenter on appear
.onAppear {
    presenter.onViewAppear()
}

// Presenter — decides which sounds to prepare
func onViewAppear() {
    interactor.prepareSoundEffect(sound: .coin, simultaneousPlayers: 4)
}

// Presenter — plays sound on user action
func onCoinCollected() {
    interactor.playSoundEffect(sound: .coin)
}

// Interactor — protocol that wraps SoundEffectManager
protocol GlobalInteractor {
    func prepareSoundEffect(sound: SoundEffectFile, simultaneousPlayers: Int)
    func playSoundEffect(sound: SoundEffectFile)
    func tearDownSoundEffect(sound: SoundEffectFile)
}
```
