
import ProjectDescription


extension Project {
    public static func createModule(
        name: String,
        platform: Platform = .iOS,
        product: Product,
        bundleID: String? = nil,
        organizationName: String = env15.organizationName,
        packages: [Package] = [],
        settings: Bool = false,
        deploymentTarget: DeploymentTarget? = nil,//env15.deploymentTarget ,
        dependencies: [TargetDependency] = [],
        baseSettings: SettingsDictionary = CSettings.defaults.value,
        configuration: Bool = false,
        coreDataModels: [ProjectDescription.CoreDataModel] = [],
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        entitlement: ProjectDescription.Path? = nil,
        infoPlist: InfoPlist = .default,
        resourceSynthesizers: [ResourceSynthesizer] = .default
    ) -> Project {
        return project(
            name: name,
            platform: platform,
            product: product,
            bundleID: bundleID,
            organizationName: organizationName,
            packages: packages,
            settings: settings,
            deploymentTarget: deploymentTarget ,
            dependencies: dependencies,
            baseSettings: baseSettings,
            configuration: configuration,
            coreDataModels: coreDataModels,
            sources: sources,
            resources: resources,
            entitlement: entitlement,
            infoPlist: infoPlist,
            resourceSynthesizers: resourceSynthesizers
        )
    }
}

public extension Project {
    static func project(
        name: String,
        platform: Platform,
        product: Product,
        bundleID: String? = nil,
        organizationName: String,
        packages: [Package],
        settings: Bool,
        deploymentTarget: DeploymentTarget?,
        dependencies: [TargetDependency] = [],
        baseSettings: SettingsDictionary = [:],
        configuration: Bool,
        coreDataModels: [ProjectDescription.CoreDataModel] = [],
        sources: SourceFilesList,
        resources: ResourceFileElements? = nil,
        entitlement: ProjectDescription.Path? = nil,
        infoPlist: InfoPlist = .default,
        resourceSynthesizers: [ResourceSynthesizer] = .default
    ) -> Project {
        
        let appTarget = Project.target(name: name,
                                       product: product,
                                       bundleID: bundleID,
                                       deploymentTarget: deploymentTarget,
                                       infoPlist: infoPlist,
                                       sources: sources,
                                       resources: resources,
                                       entitlement: entitlement,
                                       scripts: [],
                                       dependencies: dependencies,
                                       baseSettings: baseSettings,
                                       configuration: configuration ? targetSetting : defaultTargetSetting ,
                                       coreDataModels: coreDataModels)
        
        return Project(
            name: name,
            organizationName: organizationName,
            options: .options(automaticSchemesOptions: .disabled),
            packages: packages,
            settings: settings ? appBuildSetting : defalutBuildSetting,
            targets: [appTarget],
            schemes: generateSchemes(name),
            additionalFiles: [
                .glob(pattern: .relativeToRoot("Projects/CodestackApp/Config/Dev.xcconfig")),
                .glob(pattern: .relativeToRoot("Projects/CodestackApp/Config/Prod.xcconfig")),
                .glob(pattern: .relativeToRoot("Projects/CodestackApp/Config/Shared.xcconfig"))
            ],
            resourceSynthesizers: resourceSynthesizers
        )
    }
}


public enum CSettings {
    case objc
    case defaults
    
    public var value: ProjectDescription.SettingsDictionary {
        switch self {
        case .objc:
            return ["OTHER_LDFLAGS": "$(inherited) -ObjC"]
        default:
            return ["OTHER_LDFLAGS": "$(inherited)"]
        }
    }
}


public extension Project {
    static func target(
        name: String,
        product: Product,
        bundleID: String? = nil,
        deploymentTarget: DeploymentTarget?,
        infoPlist: InfoPlist = .default,
        sources: SourceFilesList,
        resources: ResourceFileElements? = nil,
        entitlement: ProjectDescription.Path? = nil,
        scripts: [TargetScript] = [],
        dependencies: [TargetDependency] = [],
        baseSettings: ProjectDescription.SettingsDictionary,
        configuration: [ProjectDescription.Configuration] = [],
        coreDataModels: [CoreDataModel] = []
    ) -> Target {
        Target(name: name,
               platform: .iOS,
               product: product,
               productName: "\(name)",
               bundleId: bundleID ?? "com.co.kr.\(name.lowercased())",
               deploymentTarget: deploymentTarget,
               infoPlist: infoPlist,
               sources: sources,
               resources: resources,
               copyFiles: nil,
               headers: nil,
               entitlements: entitlement,
               scripts: scripts,
               dependencies: dependencies,
               settings: .settings( // target settings
                base: baseSettings.merging (baseSettings) { $1 },
                configurations: configuration,
                defaultSettings:
                        .recommended (excluding: [
                            "TARGETED_DEVICE_FAMILY",])
                            //"SWIFT_ACTIVE_COMPILATION_CONDITIONS" ])
                                  ),
               coreDataModels: coreDataModels,
               environment: [ "OS_ACTIVITY_MODE" : "FALSE" ],
               launchArguments: [],
               additionalFiles: [],
               buildRules: [])
    }
}
