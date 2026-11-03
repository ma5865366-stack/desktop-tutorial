import Foundation

/// Only documented, existing MacNativeGames NSUserDefaults keys are written.
/// These are preferences, NOT proof of FPS or automatic performance tuning.
public enum M4Preset: String, CaseIterable, Identifiable {
    case battery = "省电稳定"
    case balanced = "均衡优先"
    case quality = "画质优先"

    public var id: String { rawValue }
    public var settings: [String: Any] {
        switch self {
        case .battery:
            return ["TOTK_CUSTOM_PICTURE": false, "TOTK_DOCKED": false, "TOTK_PHONE_FPS": "30"]
        case .balanced:
            return ["TOTK_CUSTOM_PICTURE": false, "TOTK_DOCKED": false, "TOTK_PHONE_FPS": "60"]
        case .quality:
            return ["TOTK_CUSTOM_PICTURE": false, "TOTK_DOCKED": true, "TOTK_PHONE_FPS": "60"]
        }
    }
    public func apply(to defaults: UserDefaults = .standard) {
        for (key, value) in settings { defaults.set(value, forKey: key) }
    }
}
