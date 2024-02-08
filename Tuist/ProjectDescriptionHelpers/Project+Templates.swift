
import ProjectDescription


extension Project {
    public static func createModule(
        name: String,
        platform: Platform = .iOS,
        product: Product,
        includeTestTarget: Bool = false,
        bundleID: String? = nil,
        organizationName: String = env15.organizationName,
        packages: [Package] = [],
        settings: Bool = false,
        deploymentTarget: DeploymentTarget = env15.deploymentTargets ,
        dependencies: [TargetDependency] = [],
        baseSettings: SettingsDictionary = CSettings.defaults.value,
        configuration: Bool = false,
        coreDataModels: [ProjectDescription.CoreDataModel] = [],
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        entitlement: Path? = nil,
        infoPlist: InfoPlist = .default,
        resourceSynthesizers: [ResourceSynthesizer] = .default
    ) -> Project {
        return project(
            name: name,
            platform: platform,
            product: product,
            includeTestTarget: includeTestTarget,
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
        includeTestTarget: Bool,
        bundleID: String?,
        organizationName: String,
        packages: [Package],
        settings: Bool,
        deploymentTarget: DeploymentTarget,
        dependencies: [TargetDependency],
        baseSettings: SettingsDictionary,
        configuration: Bool,
        coreDataModels: [ProjectDescription.CoreDataModel],
        sources: SourceFilesList,
        resources: ResourceFileElements?,
        entitlement: Path?,
        infoPlist: InfoPlist,
        resourceSynthesizers: [ResourceSynthesizer]
    ) -> Project {
        
        var bundleID = bundleID ?? "com.co.kr.\(name.lowercased())"
        var appTargets: [ProjectDescription.Target] = []
        
        let appTarget = Project.target(name: name,
                                    product: product,
                                    bundleID: bundleID,
                                    deploymentTargets: deploymentTarget,
                                    infoPlist: infoPlist,
                                    sources: sources,
                                    resources: resources,
                                    entitlement: entitlement,
                                    scripts: [],
                                    dependencies: dependencies,
                                    baseSettings: baseSettings,
                                    configuration: configuration ? targetSetting : defaultTargetSetting ,
                                    coreDataModels: coreDataModels)
        appTargets.append(appTarget)
        
        if includeTestTarget {
            let testTarget = Target(
                name: "\(name)Tests",
                platform: platform,
                product: .unitTests,
                bundleId: "\(bundleID).\(name)Tests",
                deploymentTarget: deploymentTarget,
                infoPlist: .default,
                sources: ["Tests/**"],
                entitlements: entitlement,
                dependencies: [.target(name: "\(name)")],
                settings: .settings(configurations: defaultTargetSetting)
            )
            appTargets.append(testTarget)
        }
        
        return Project(
            name: name,
            organizationName: organizationName,
            options: .options(automaticSchemesOptions: .disabled),
            packages: packages,
            settings: settings ? appBuildSetting : defalutBuildSetting,
            targets: appTargets,
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


public extension Project {
    static func target(
        name: String,
        product: Product,
        bundleID: String,
        deploymentTargets: DeploymentTarget,
        infoPlist: InfoPlist,
        sources: SourceFilesList,
        resources: ResourceFileElements?,
        entitlement: Path?,
        scripts: [TargetScript],
        dependencies: [TargetDependency],
        baseSettings: ProjectDescription.SettingsDictionary,
        configuration: [ProjectDescription.Configuration],
        coreDataModels: [CoreDataModel]
    ) -> Target {
        Target(name: name,
               platform: .iOS,
               product: product,
               productName: "\(name)",
               bundleId: bundleID,
               deploymentTarget: deploymentTargets,
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
                defaultSettings: .recommended (excluding: [ "TARGETED_DEVICE_FAMILY",])
                                  ),
               coreDataModels: coreDataModels,
               environment: [ "OS_ACTIVITY_MODE" : "FALSE" ],
               launchArguments: [],
               additionalFiles: [],
               buildRules: [])
    }
}
