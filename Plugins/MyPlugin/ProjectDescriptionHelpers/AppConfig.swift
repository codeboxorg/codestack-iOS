@preconcurrency import ProjectDescription

public enum AppConfig {
    public static let orgName = "com.hwan"
    public static let appBundleID = "kr.co.codestack.ios"
    public static let deploymentTarget: DeploymentTargets = .iOS("15.0")
    public static let defaultSettings: SettingsDictionary = [
        "ENABLE_BITCODE": "NO"
    ]
    
    public static func demoAppSceneDeleateSetting(name: String) -> [String: Plist.Value] {
        [
            "UILaunchStoryboardName": "LaunchScreen.storyboard",
            "UIApplicationSceneManifest": [
                "UIApplicationSupportsMultipleScenes": true,
                "UISceneConfigurations": [
                    "UIWindowSceneSessionRoleApplication": [
                        [
                            "UISceneConfigurationName": "Default Configuration",
                            "UISceneDelegateClassName": "\(name)Demo.SceneDelegate"
                        ]
                    ]
                ]
            ],
            "Judge0APIURL": "$(JUDGE0_API_URL)"
        ]
    }
    
    // SWIFT_ACTIVE_COMPILATION_CONDITIONS=
    public static func projectConfiguration() -> Settings {
        .settings(
            configurations:
                [
                    .debug(name: BuildConfig.dev.configName, xcconfig: .relativeToXCConfig(type: .dev)),
                    .release(name: BuildConfig.prod.configName, xcconfig: .relativeToXCConfig(type: .prod))
                ],
            defaultSettings: .recommended
        )
    }
    public static func targetConfiguration(path: String) -> Settings {
        .settings(
            configurations:
                [
                    .debug(name: BuildConfig.dev.configName, xcconfig: .relativeToXCConfig(path: path)),
                    .release(name: BuildConfig.prod.configName, xcconfig: .relativeToXCConfig(path: path))
                ],
            defaultSettings: .recommended
        )
    }
    
    public static func demoProjectConfiguration(path: String) -> Settings {
        .settings(
            configurations:
                [
                    .debug(name: BuildConfig.dev.configName, xcconfig: .relativeToXCConfig(path: path)),
                    .release(name: BuildConfig.prod.configName, xcconfig: .relativeToXCConfig(path: path))
                ],
            defaultSettings: .recommended
        )
    }
}

/// Project Module 생성 함수 팬텀 enum
public enum ProjectFactory { }

