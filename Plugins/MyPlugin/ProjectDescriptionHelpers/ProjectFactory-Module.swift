
@preconcurrency import ProjectDescription


public extension ProjectFactory {
    static func createModule(
        name: String,
        product: Product,
        platform: Platform = .iOS,
        resources: ResourceFileElements? = ["Resources/**"],
        entitlements: Entitlements? = nil,
        dependencies: [TargetDependency] = [],
        infoPlist: InfoPlist = .default,
        coreDataModel: [CoreDataModel] = []
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
                    settings: AppConfig.targetConfiguration(path: name),
                    coreDataModels: coreDataModel
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
                .makeScheme(config: .dev, name: name),
                .makeScheme(config: .prod, name: name)
            ],
            additionalFiles: [.glob(pattern: .relativeToXCConfig(path: "shared"))]
        )
    }
}
