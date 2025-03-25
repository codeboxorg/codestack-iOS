//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 12/17/23.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin


let baseSetting: SettingsDictionary =
["HEADER_SEARCH_PATHS": [
    "$(inherited)",
    "$(SRCROOT)/../../Tuist/Dependencies/SwiftPackageManager/.build/checkouts/GTMAppAuth/GTMAppAuth/Sources/Public/GTMAppAuth",
    "$(SRCROOT)/../../Tuist/Dependencies/SwiftPackageManager/.build/checkouts/gtm-session-fetcher/Sources/Core/Public"
],
 "OTHER_LDFLAGS" : "$(OTHER_LDFLAGS) -ObjC"]


let project = ProjectFactory
    .createModule(
        name: "CSNetowrk",
        product: .staticFramework
    )

//let project = Project.createModule(
//    name: "CSNetwork",
//    product: .staticFramework,
//    dependencies: [.PRO.global,.PRO.thridParty],
//    baseSettings: baseSetting
//)
