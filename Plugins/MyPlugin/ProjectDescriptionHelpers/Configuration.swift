@preconcurrency import ProjectDescription

public enum BuildConfig: String {
    case dev = "DEV"
    case prod = "PROD"
    public var configName: ConfigurationName {
        return ConfigurationName.configuration(self.rawValue)
    }
}

extension Path {
    public static func relativeToXCConfig(type: BuildConfig) -> Self {
        return .relativeToRoot("../Codestack/Config/\(type.rawValue.lowercased()).xcconfig")
    }
    public static func relativeToXCConfig(path: String) -> Self {
        return .relativeToRoot("../Codestack/Config/\(path).xcconfig")
    }
}

extension Configuration {
    public static func build(_ type: BuildConfig, name: String = "") -> Self {
        let buildName = type.rawValue
        switch type {
        case .dev:
            return .debug(
                name: BuildConfig.dev.configName,
                xcconfig: .relativeToXCConfig(type: .dev)
            )
        case .prod:
            return .release(
                name: BuildConfig.prod.configName,
                xcconfig: .relativeToXCConfig(type: .prod)
            
            )
        }
    }
}
