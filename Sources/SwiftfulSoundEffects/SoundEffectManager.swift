import Foundation
import AVKit

public final actor SoundEffectManager {

    private let logger: SoundEffectLogger?
    private var allPlayers: [AVAudioPlayer] = []
    private var counters: [URL: Int] = [:]

    public init(logger: SoundEffectLogger? = nil) {
        self.logger = logger
    }

    // MARK: PREPARE

    /// Prepares the specified sound effect for playback by creating and configuring players.
    ///
    /// - Parameters:
    ///   - url: The URL of the audio file to prepare.
    ///   - simultaneousPlayers: The number of players to create for the sound effect. If there is only one player, calling play() will restart that sound, even if a previous play() is still playing. Add multiple players to support simultaneous playing of the same sound. Default is `1`.
    ///   - volume: The playback volume for the players, ranging from `0.0` (mute) to `1.0` (maximum volume). Default is `1.0`.
    ///
    /// This function ensures that the required number of players are prepared to play the sound.
    /// If more players are needed, new players will be created and configured.
    public nonisolated func prepareSoundEffect(url: URL, simultaneousPlayers: Int = 1, volume: Float = 1) {
        Task {
            await _prepare(url: url, simultaneousPlayers: simultaneousPlayers, volume: volume)
        }
    }

    // MARK: PLAY

    /// Plays the sound effect associated with the specified URL.
    ///
    /// - Parameter url: The URL of the audio file to play.
    ///
    /// This function uses a round-robin mechanism to select the next available player for the URL.
    /// You must call prepareSoundEffect() before playSoundEffect() in order to create the available players.
    /// If the next available player is already playing, playback will restart. To avoid this, add more simultaneousPlayers via prepareSoundEffect()
    public nonisolated func playSoundEffect(url: URL) {
        Task {
            await _play(url: url)
        }
    }

    // MARK: TEAR DOWN

    /// Stops and removes all players associated with the specified sound effect.
    ///
    /// - Parameter url: The URL of the audio file whose players should be removed.
    ///
    /// Use this method to release resources when the sound effect is no longer needed.
    public nonisolated func tearDownSoundEffect(url: URL) {
        Task {
            await _tearDown(url: url)
        }
    }

    // MARK: PRIVATE

    private func _prepare(url: URL, simultaneousPlayers: Int, volume: Float) {
        do {
            let existingPlayers = allPlayers.filter({ $0.url == url }).count
            let newPlayersRequired = simultaneousPlayers - existingPlayers
            var newPlayers: [AVAudioPlayer] = []

            if newPlayersRequired > 0 {
                for _ in 0..<newPlayersRequired {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.volume = volume
                    player.prepareToPlay()
                    newPlayers.append(player)
                }
            }

            allPlayers.append(contentsOf: newPlayers)
        } catch {
            trackEvent(event: .failedToPreparePlayer(error: error))
        }
    }

    private func _tearDown(url: URL) {
        allPlayers.forEach { player in
            if player.url == url {
                player.stop()
            }
        }

        allPlayers.removeAll(where: { $0.url == url })
    }

    private func _play(url: URL) {
        let currentIndex = counters[url] ?? 0

        guard let (nextPlayer, nextIndex) = allPlayers.findNext(startingAt: currentIndex, where: { $0.url == url }) else {
            trackEvent(event: .playerNotFound)
            return
        }

        counters[url] = nextIndex + 1
        playPlayer(nextPlayer)
    }

    private func playPlayer(_ player: AVAudioPlayer) {
        if player.isPlaying {
            player.currentTime = 0
            player.play()
        } else {
            player.play()
        }
    }

    private func trackEvent(event: Event) {
        Task {
            await logger?.trackEvent(event: event)
        }
    }
}

extension SoundEffectManager {

    enum Event: SoundEffectLogEvent {
        case failedToPreparePlayer(error: Error)
        case playerNotFound

        var eventName: String {
            switch self {
            case .failedToPreparePlayer:          return "SoundEffects_Prepare_Fail"
            case .playerNotFound:                 return "SoundEffects_Play_Fail"
            }
        }

        var parameters: [String : Any]? {
            switch self {
            case .failedToPreparePlayer(let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: SoundEffectLogType {
            switch self {
            case .failedToPreparePlayer:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
