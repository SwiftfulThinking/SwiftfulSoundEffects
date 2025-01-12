# SwiftfulSoundEffects 🎧

SoundEffectManager helper class for playing simultaneous sound effects.

## Setup

```swift
import SwiftfulSoundEffects

let soundEffectManager = SoundEffectManager(logger: SoundEffectLogger?)
let soundEffectManager = SoundEffectManager()
```

## Usage

Call prepare prior to playing a sound. This is required. 
- If there is only one player, calling play() will restart that sound, even if a previous play() is still playing. Add simultaneousPlayers to support simultaneous playing of the same sound.

```swift
Task {
     await soundEffectManager.prepare(url: url, simultaneousPlayers: 1, volume: 1)
     await soundEffectManager.prepare(url: url, simultaneousPlayers: 6, volume: 1)
}
```

Then call play to play the sound effect. 
- You must call prepare() before play() in order to create the available players.
- If the next available player is already playing, playback will restart. To avoid this, add more simultaneousPlayers via prepare().

```swift
Task {
     await soundEffectManager.play(url: url)
}
```

Call tearDown to remove the audio players from memory. This is not required.

```swift
Task {
     await soundEffectManager.tearDown(url: url)
}
```

Sample SoundEffectFile (not included):

```swift
enum SoundEffectFile: String, Equatable {
    case sample
    
    var fileName: String {
        switch self {
        case .sample:
            return "Sample.wav"
        }
    }
    
    var url: URL {
        let path = Bundle.main.path(forResource: fileName, ofType: nil)!
        return URL(fileURLWithPath: path)
    }
}
```





