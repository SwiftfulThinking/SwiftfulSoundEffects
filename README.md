# SwiftfulSoundEffects 🎧

An actor-based sound effect library for iOS and macOS. SwiftfulSoundEffects manages multiple AVAudioPlayers with round-robin playback for simultaneous sound effects.

## Features

- **Thread-safe actor-based design** with modern Swift concurrency
- **Simple synchronous API** with async behavior internalized
- **Simultaneous playback** via configurable player pools per sound
- **Round-robin player selection** for overlapping sound effects
- **Memory management** with selective teardown per sound
- **Optional logging** for analytics integration

## Setup

<details>
<summary> Details (Click to expand) </summary>
<br>

Add SwiftfulSoundEffects to your project.

```
https://github.com/SwiftfulThinking/SwiftfulSoundEffects.git
```

Import the package.

```swift
import SwiftfulSoundEffects
```

Create a `SoundEffectManager` instance.

```swift
// Basic setup
let soundEffectManager = SoundEffectManager()

// With optional logger for analytics
let soundEffectManager = SoundEffectManager(logger: yourLogger)
```

</details>

## Quick Start

<details>
<summary> Details (Click to expand) </summary>
<br>

Prepare a sound effect, then play it.

```swift
let url = Bundle.main.url(forResource: "coin", withExtension: "wav")!

// Prepare the player
soundEffectManager.prepareSoundEffect(url: url)

// Play when needed
soundEffectManager.playSoundEffect(url: url)

// Clean up when done (optional)
soundEffectManager.tearDownSoundEffect(url: url)
```

For sounds that overlap (e.g. rapid coin collection), add simultaneous players.

```swift
soundEffectManager.prepareSoundEffect(url: url, simultaneousPlayers: 6)
```

</details>

## API Reference

<details>
<summary> Details (Click to expand) </summary>
<br>

All public methods are **synchronous** (`nonisolated`) with async behavior handled internally.

```swift
// Preparation (required before playing)
func prepareSoundEffect(url: URL, simultaneousPlayers: Int = 1, volume: Float = 1)

// Playback
func playSoundEffect(url: URL)

// Memory management (optional)
func tearDownSoundEffect(url: URL)
```

### When to Use Each Method

**`prepareSoundEffect()`** — Required before playing
- Creates one or more `AVAudioPlayer` instances for the given URL
- `simultaneousPlayers` controls how many players are created per sound
- With 1 player (default): calling `playSoundEffect()` while already playing restarts the sound
- With multiple players: supports overlapping playback of the same sound via round-robin
- `volume` sets playback volume from `0.0` (mute) to `1.0` (max)

**`playSoundEffect()`** — Core functionality
- Selects the next player for the URL using round-robin
- If the selected player is already playing, playback restarts from the beginning
- Thread-safe: can be called from any context

**`tearDownSoundEffect()`** — Optional memory management
- Stops and removes all players for the given URL
- Call during screen disappear or when a sound is no longer needed

</details>

## Simultaneous Playback

<details>
<summary> Details (Click to expand) </summary>
<br>

By default, each sound gets 1 player. If you `playSoundEffect()` while it's still playing, the sound restarts.

To support overlapping playback (e.g. rapid coin sounds), prepare with multiple players:

```swift
// 1 player — playSoundEffect() restarts if already playing
soundEffectManager.prepareSoundEffect(url: coinURL)

// 6 players — supports up to 6 overlapping plays
soundEffectManager.prepareSoundEffect(url: coinURL, simultaneousPlayers: 6)
```

Players are selected round-robin. If all players are busy, the next one restarts.

</details>

## SoundEffectFile Pattern

<details>
<summary> Details (Click to expand) </summary>
<br>

Create an enum to manage your sound files (not included in the package).

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

Then use it with the manager:

```swift
soundEffectManager.prepareSoundEffect(url: SoundEffectFile.coin.url, simultaneousPlayers: 4)
soundEffectManager.playSoundEffect(url: SoundEffectFile.coin.url)
```

</details>

## Logging Integration

<details>
<summary> Details (Click to expand) </summary>
<br>

SwiftfulSoundEffects supports optional logging for analytics.

```swift
// Implement the SoundEffectLogger protocol
class MyAnalytics: SoundEffectLogger {
    func trackEvent(event: SoundEffectLogEvent) {
        print("SoundEffect: \(event.eventName)")
    }

    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        // Add user properties for analytics
    }
}

// Initialize with logger
let soundEffectManager = SoundEffectManager(logger: MyAnalytics())
```

Or use [SwiftfulLogging](https://github.com/SwiftfulThinking/SwiftfulLogging) directly.

```swift
let logManager = LogManager(services: [
    ConsoleService(printParameters: true),
    FirebaseCrashlyticsService(),
    MixpanelService()
])

let soundEffectManager = SoundEffectManager(logger: logManager)
```

</details>

## Performance Tips

<details>
<summary> Details (Click to expand) </summary>
<br>

1. **Always call prepareSoundEffect() before playSoundEffect()** — play does nothing if no players exist
2. **Use tearDownSoundEffect()** during screen disappear or memory warnings
3. **Choose simultaneousPlayers wisely** — more players = more memory, but supports overlapping
4. **Use lower volume** for ambient or background sounds to blend with other audio

</details>

## Claude Code

This package includes a `.claude/swiftful-sound-effects-rules.md` with usage guidelines and integration patterns for projects using [Claude Code](https://claude.ai/claude-code).

## Platform Support

- **iOS 16.0+**
- **macOS 12.0+**

## License

SwiftfulSoundEffects is available under the MIT license.
