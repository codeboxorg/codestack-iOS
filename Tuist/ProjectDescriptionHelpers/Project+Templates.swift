
import ProjectDescription


extension Project {
    public static func createModule(
        name: String,
        platform: Platform = .iOS,
        product: Product,
        includeTestTarget: Bool = false,
        hostTargetNeeded: Bool = false,
        bundleID: String? = nil,
        organizationName: String = env15.organizationName,
        packages: [Package] = [],
        settings: Bool = false,
        deploymentTarget: DeploymentTargets = env15.deploymentTarget ,
        dependencies: [TargetDependency] = [],
        baseSettings: SettingsDictionary = CSettings.defaults.value,
        configuration: Bool = false,
        coreDataModels: [ProjectDescription.CoreDataModel] = [],
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        entitlement: Entitlements? = nil,
        script: [TargetScript] = [],
        infoPlist: InfoPlist = .default,
        resourceSynthesizers: [ResourceSynthesizer] = .default,
        scripts: [TargetScript] = []
    ) -> Project {
        return project(
            name: name,
            platform: platform,
            product: product,
            includeTestTarget: includeTestTarget,
            hostTargetNeeded: hostTargetNeeded,
            bundleID: bundleID,
            organizationName: organizationName,
            packages: packages,
            settings: settings,
            deploymentTarget: deploymentTarget,
            dependencies: dependencies,
            baseSettings: baseSettings,
            configuration: configuration,
            coreDataModels: coreDataModels,
            sources: sources,
            resources: resources,
            entitlement: entitlement,
            script: script,
            infoPlist: infoPlist,
            resourceSynthesizers: resourceSynthesizers,
            scripts: scripts
        )
    }
}

public extension Project {
    static func project(
        name: String,
        platform: Platform,
        product: Product,
        includeTestTarget: Bool,
        hostTargetNeeded: Bool,
        bundleID: String?,
        organizationName: String,
        packages: [Package],
        settings: Bool,
        deploymentTarget: DeploymentTargets,
        dependencies: [TargetDependency],
        baseSettings: SettingsDictionary,
        configuration: Bool,
        coreDataModels: [ProjectDescription.CoreDataModel],
        sources: SourceFilesList,
        resources: ResourceFileElements?,
        entitlement: Entitlements?,
        script: [TargetScript],
        infoPlist: InfoPlist,
        resourceSynthesizers: [ResourceSynthesizer],
        scripts: [TargetScript]
    ) -> Project {
        
        var appTargets: [ProjectDescription.Target] = []
        var testTargetDependency: [TargetDependency] = []
        
        let appTarget = Target.target(
            name: name,
            destinations: .iOS,
            product: product,
            bundleId: bundleID ?? "\(organizationName).\(name)",
            deploymentTargets: env15.deploymentTarget,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlement,
            scripts: script,
            dependencies: dependencies,
            settings: .settings( // target settings
             base: baseSettings.merging (baseSettings) { $1 },
             configurations: configuration ? targetSetting : defaultTargetSetting,
             defaultSettings: .recommended (excluding: [ "TARGETED_DEVICE_FAMILY",])
                               ),
            coreDataModels: coreDataModels
        )

        appTargets.append(appTarget)
        testTargetDependency.append(.target(name: "\(name)"))
        
        if hostTargetNeeded {
            let hostTarget = Target.target(
                name: "\(name)DemoApp",
                destinations: .iOS,
                product: .app,
                bundleId: "\(String(describing: bundleID)).\(name)Demo",
                deploymentTargets: deploymentTarget,
                infoPlist: .default,
                sources: ["Demo/**"],
                resources: [
                    .glob(pattern: .relativeToRoot("Projects/CodestackApp/Config/GoogleService-Info.plist"),
                          excluding: [],
                          tags: [])
                ],
                entitlements: entitlement,
                scripts: script,
                dependencies: [ .target(name: "\(name)")],
                settings: .settings(
                    base: baseSettings.merging (baseSettings) { $1 },
                    configurations: defaultTargetSetting,
                    defaultSettings: .recommended (excluding: [ "TARGETED_DEVICE_FAMILY",])
                ),
                coreDataModels: coreDataModels
            )
            
            appTargets.append(hostTarget)
            testTargetDependency.append(.target(name: "\(name)Demo"))
        }
        
        if includeTestTarget {
            let testTarget = Target.target(
                name: "\(name)Tests",
                destinations: .iOS,
                product: .unitTests,
                bundleId: "\(organizationName).\(name)Tests",
                deploymentTargets: env15.deploymentTarget,
                infoPlist: .default,
                sources: ["Tests/**"],
                entitlements: entitlement,
                dependencies: [.target(name: name)],
                settings: .settings(
                    base: ["ENABLE_MODULE_VERIFIER": "YES"],
                    configurations: []
                )
            )
            appTargets.append(testTarget)
        }
        
        let scheme: [Scheme] =
        hostTargetNeeded ?
        [
            .makeScheme(target: .configuration("Dev"), name: name),
            .makeScheme(target: .configuration("Prod"), name: name),
            .makeDemoScheme(target: .configuration("Dev"), name: name)
        ]
        :
        [
            .makeScheme(target: .configuration("Dev"), name: name),
            .makeScheme(target: .configuration("Prod"), name: name)
        ]
        
        return Project(
            name: name,
            organizationName: organizationName,
            options: .options(automaticSchemesOptions: .disabled),
            packages: packages,
            settings: settings ? appBuildSetting : defalutBuildSetting,
            targets: appTargets,
            schemes: scheme,
            additionalFiles: [
                .glob(pattern: .relativeToRoot("Projects/CodestackApp/Config/Dev.xcconfig")),
                .glob(pattern: .relativeToRoot("Projects/CodestackApp/Config/Prod.xcconfig")),
                .glob(pattern: .relativeToRoot("Projects/CodestackApp/Config/Shared.xcconfig"))
            ],
            resourceSynthesizers: resourceSynthesizers
        )
    }
}

extension Scheme {
    static func makeScheme(target: ConfigurationName, name: String) -> Scheme {
        return Scheme.scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            testAction: .targets(
                ["\(name)Tests"],
                configuration: target,
                options: .options(coverage: true, codeCoverageTargets: ["\(name)"])
            ),
            runAction: .runAction(configuration: target),
            archiveAction: .archiveAction(configuration: target),
            profileAction: .profileAction(configuration: target),
            analyzeAction: .analyzeAction(configuration: target)
        )
    }
    static func makeDemoScheme(target: ConfigurationName, name: String) -> Scheme {
        return Scheme.scheme(
               name: name,
               shared: true,
               buildAction: .buildAction(targets: ["\(name)DemoApp"]),
               testAction: .targets(
                   ["\(name)Tests"],
                   configuration: target,
                   options: .options(coverage: true, codeCoverageTargets: ["\(name)DemoApp"])
               ),
               runAction: .runAction(configuration: target),
               archiveAction: .archiveAction(configuration: target),
               profileAction: .profileAction(configuration: target),
               analyzeAction: .analyzeAction(configuration: target)
           )
       }
}

//public extension Project {
//    static func target(
//        name: String,
//        product: Product,
//        bundleID: String,
//        deploymentTargets: DeploymentTarget,
//        infoPlist: InfoPlist,
//        sources: SourceFilesList,
//        resources: ResourceFileElements?,
//        entitlement: Path?,
//        scripts: [TargetScript],
//        dependencies: [TargetDependency],
//        baseSettings: ProjectDescription.SettingsDictionary,
//        configuration: [ProjectDescription.Configuration],
//        coreDataModels: [CoreDataModel]
//    ) -> Target {
//        Target(name: name,
//               platform: .iOS,
//               product: product,
//               productName: "\(name)",
//               bundleId: bundleID,
//               deploymentTarget: deploymentTargets,
//               infoPlist: infoPlist,
//               sources: sources,
//               resources: resources,
//               copyFiles: nil,
//               headers: nil,
//               entitlements: entitlement,
//               scripts: scripts,
//               dependencies: dependencies,
//               settings: .settings( // target settings
//                base: baseSettings.merging (baseSettings) { $1 },
//                configurations: configuration,
//                defaultSettings: .recommended (excluding: [ "TARGETED_DEVICE_FAMILY",])
//                                  ),
//               coreDataModels: coreDataModels,
//               environment: [ "OS_ACTIVITY_MODE" : "FALSE" ],
//               launchArguments: [],
//               additionalFiles: [],
//               buildRules: [])
//    }
//}
