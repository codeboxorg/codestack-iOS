
import ProjectDescription

/*
                +-------------+
                |             |
                |     App     | Contains MyApp App target and MyApp unit-test target
                |             |
         +------+-------------+-------+
         |         depends on         |
         |                            |
 +----v-----+                   +-----v-----+
 |          |                   |           |
 |   Kit    |                   |     UI    |   Two independent frameworks to share code and start modularising your app
 |          |                   |           |
 +----------+                   +-----------+

 */


// Creates our project using a helper function defined in ProjectDescriptionHelpers

let workspace = Workspace(
    name: "CodeStackApp",
    projects: [
        "Projects/CodestackApp",
        "Projects/Global",
        "Projects/Data",
        "Projects/Domain"
    ])
//let project = Project.app(name: "MyApp",
//                          platform: .iOS,
//                          additionalTargets: ["MyAppKit", "MyAppUI"])
//
//let coreProject = Project.app(name: "Core",
//                              platform: .iOS,
//                              additionalTargets: ["Network", "Repository" ])
// Users/baghyeonghwan/MyApp/Projects/MyAppUI
//'/Users/baghyeonghwan/MyApp/Projects/MyAppUI'

//let workspace = Workspace (
//    name: "MyApp", projects: [
//        "Projects/MyApp",
//        "Projects/MyAppKit",
//        "Projects/MyAppUI",
//        "Projects/Network",
//        "Projects/Repository"
//        ],
//    generationOptions: .options(enableAutomaticXcodeSchemes: false,
//                                autogeneratedWorkspaceSchemes:
//            .enabled(codeCoverageMode: .relevant))
//    )
