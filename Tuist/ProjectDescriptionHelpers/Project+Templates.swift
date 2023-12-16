
import ProjectDescription


extension Project {
    public static func createModule(
        name: String,
        platform: Platform = .iOS,
        product: Product,
        bundleID: String? = nil,
        packages: [Package] = [],
        settings: Bool = false,
        dependencies: [TargetDependency] = [],
        configuration: Bool = false,
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
            packages: packages,
            settings: settings,
            dependencies: dependencies,
            configuration: configuration,
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
        organizationName: String = env.organizationName,
        packages: [Package],
        settings: Bool,
        deploymentTarget: DeploymentTarget? = env.deploymentTarget,
        dependencies: [TargetDependency] = [],
        configuration: Bool,
        sources: SourceFilesList,
        resources: ResourceFileElements? = nil,
        entitlement: ProjectDescription.Path? = nil,
        infoPlist: InfoPlist = .default,
        resourceSynthesizers: [ResourceSynthesizer] = .default
    ) -> Project {
        
        let appTarget = Project.target(name: name,
                                    product: product,
                                    bundleID: bundleID,
                                    infoPlist: infoPlist,
                                    sources: sources,
                                    resources: resources,
                                    entitlement: entitlement,
                                    scripts: [],
                                    dependencies: dependencies,
                                    configuration: configuration ? targetSetting : defaultTargetSetting ,
                                    coreDataModels: [])
        
        return Project(
            name: name,
            organizationName: organizationName,
            options: .options(automaticSchemesOptions: .disabled),
            packages: packages,
            settings: settings ? appBuildSetting : defalutBuildSetting,
            targets: [appTarget],
            schemes: generateSchemes(name),
            resourceSynthesizers: resourceSynthesizers
        )
    }
}




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
