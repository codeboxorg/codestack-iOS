

@preconcurrency import ProjectDescription
import MyPlugin
import ProjectDescriptionHelpers

let project = ProjectFactory.createModuleWithDemo(
    name: "Editor",
    product: .staticFramework,
    dependencies: [
        .SPM.snapKit,
        .SPM.then,
        .PRO.commonUI,
        .SPM.highlightr,
        .PRO.global
    ]
)

