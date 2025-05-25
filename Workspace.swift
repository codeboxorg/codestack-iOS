
@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(
    name: "CodeStackApp",
    projects: [
        P.app,
        P.data,
        P.domain,
        P.csNetwork,
        P.global,
        P.thirdParty,
        P.commonUI,
        P.editor
        //P.presentation
    ])
