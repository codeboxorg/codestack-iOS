
import ProjectDescription

public extension Project {
    
    static func target(
        name: String,
        product: Product,
        bundleID: String? = nil,
        infoPlist: InfoPlist = .default,
        sources: SourceFilesList,
        resources: ResourceFileElements? = nil,
        entitlement: ProjectDescription.Path? = nil,
        scripts: [TargetScript] = [],
        dependencies: [TargetDependency] = [],
        baseSettings: ProjectDescription.SettingsDictionary = [:],
        configuration: [ProjectDescription.Configuration] = [],
        coreDataModels: [CoreDataModel] = []
    ) -> Target {
        Target(name: name,
               platform: .iOS,
               product: product,
               productName: "\(name)",
               bundleId: bundleID ?? "com.co.kr.\(name.lowercased())",
               deploymentTarget: .iOS(targetVersion: "15.0", devices: .iphone, supportsMacDesignedForIOS: false),
               infoPlist: infoPlist,
               sources: sources,
               resources: resources,
               copyFiles: nil,
               headers: nil,
               entitlements: entitlement,
               scripts: scripts,
               dependencies: dependencies,
               settings: .settings( // target settings
                base: [
                    "OTHER_LDFLAGS": "$(inherited) "
                ].merging (baseSettings) { $1 },
                configurations: configuration,
                defaultSettings:
                        .recommended (excluding: [
                            "TARGETED_DEVICE_FAMILY",
                            "SWIFT_ACTIVE_COMPILATION_CONDITIONS"])
                                  ),
               coreDataModels: coreDataModels,
               environment: [ "OS_ACTIVITY_MODE" : "FALSE" ],
               launchArguments: [],
               additionalFiles: [],
               buildRules: [])
    }
}
