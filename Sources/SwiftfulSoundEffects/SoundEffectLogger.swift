//
//  SoundEffectLogger.swift
//  SwiftfulSoundEffects
//
//  Created by Nick Sarno on 1/12/25.
//

@MainActor
public protocol SoundEffectLogger {
    func trackEvent(event: SoundEffectLogEvent)
    func addUserProperties(dict: [String: Any], isHighPriority: Bool)
}

public protocol SoundEffectLogEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: SoundEffectLogType { get }
}

public enum SoundEffectLogType: Int, CaseIterable, Sendable {
    case info // 0
    case analytic // 1
    case warning // 2
    case severe // 3

    var emoji: String {
        switch self {
        case .info:
            return "👋"
        case .analytic:
            return "📈"
        case .warning:
            return "⚠️"
        case .severe:
            return "🚨"
        }
    }

    var asString: String {
        switch self {
        case .info: return "info"
        case .analytic: return "analytic"
        case .warning: return "warning"
        case .severe: return "severe"
        }
    }
}
