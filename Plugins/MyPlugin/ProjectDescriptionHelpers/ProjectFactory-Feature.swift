
@preconcurrency import ProjectDescription



public extension ProjectFactory {
    static func createModuleWithDemo(
        name: String,
        product: Product,
        platform: Platform = .iOS,
        resources: ResourceFileElements? = ["Resources/**"],
        entitlements: Entitlements? = nil,
        dependencies: [TargetDependency] = [],
        infoPlist: InfoPlist = .default
    ) -> Project {
        Project(
            name: name,
            organizationName: AppConfig.orgName,
            options: .options(automaticSchemesOptions: .disabled),
            settings: AppConfig.projectConfiguration(),
            targets: [
                .target(
                    name: name,
                    destinations: .iOS,
                    product: product,
                    bundleId: "\(AppConfig.orgName).\(name)",
                    deploymentTargets: AppConfig.deploymentTarget,
                    infoPlist: infoPlist,
                    sources: ["Sources/**"],
                    resources: resources,
                    dependencies: dependencies,
                    settings: AppConfig.targetConfiguration(path: name)
                ),
                
                .target(
                    name: "\(name)Demo",
                    destinations: .iOS,
                    product: .app,
                    bundleId: "\(AppConfig.orgName).\(name)Demo",
                    deploymentTargets: AppConfig.deploymentTarget,
                    infoPlist: .extendingDefault(with: AppConfig.demoAppSceneDeleateSetting(name: name)),
                    sources: ["\(name)Demo/**"],
                    resources: ["\(name)Demo/Resources/**"],
                    dependencies: [
                        .target(name: name)
                    ],
                    settings: AppConfig.demoProjectConfiguration(path: name)
                ),
                .target(
                    name: "\(name)DemoTests",
                    destinations: .iOS,
                    product: .unitTests,
                    bundleId: "\(AppConfig.orgName).\(name)DemoTests",
                    deploymentTargets: AppConfig.deploymentTarget,
                    infoPlist: .default,
                    sources: ["\(name)Demo/Tests/**"],
                    dependencies: [
                        .target(name: "\(name)Demo")
                    ]
                ),
                .target(
                    name: "\(name)DemoUITests",
                    destinations: .iOS,
                    product: .uiTests,
                    bundleId: "\(AppConfig.orgName).\(name)DemoUITests",
                    deploymentTargets: AppConfig.deploymentTarget,
                    infoPlist: .default,
                    sources: ["\(name)Demo/UITests/**"],
                    dependencies: [
                        .target(name: "\(name)Demo")
                    ]
                ),
                .target(
                    name: "\(name)Tests",
                    destinations: .iOS,
                    product: .unitTests,
                    bundleId: "\(AppConfig.orgName).\(name)Tests",
                    deploymentTargets: AppConfig.deploymentTarget,
                    infoPlist: .default,
                    sources: ["Tests/**"],
                    dependencies: [
                        .target(name: name)
                    ],
                    settings: .settings(base: ["ENABLE_MODULE_VERIFIER": "YES"], configurations: [])
                )
            ],
            schemes: [
                .makeDemoScheme(name: name),
                .makeScheme(config: .dev, name: name),
                .makeScheme(config: .prod, name: name)
            ],
            additionalFiles: [.glob(pattern: .relativeToXCConfig(path: "shared"))]
        )
    }
}
