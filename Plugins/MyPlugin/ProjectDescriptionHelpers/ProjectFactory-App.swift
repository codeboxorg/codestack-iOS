
@preconcurrency import ProjectDescription



public extension ProjectFactory {
    static func createApp(
        name: String,
        product: Product = .app,
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
                    product: .app,
                    bundleId: AppConfig.appBundleID,
                    deploymentTargets: AppConfig.deploymentTarget,
                    infoPlist: infoPlist,
                    sources: ["Sources/**"],
                    resources: resources,
                    dependencies: dependencies,
                    settings: AppConfig.targetConfiguration(path: name)
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
                    settings: .settings(base: ["ENABLE_MODULE_VERIFIER": "YES"], configurations: []),
                    additionalFiles: [.glob(pattern: .relativeToXCConfig(path: "shared"))]
                )
            ],
            schemes: [
                .makeScheme(config: .dev, name: name),
                .makeScheme(config: .prod, name: name)
            ]
        )
    }
}
