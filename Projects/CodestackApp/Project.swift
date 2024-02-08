//
//  Project.swift
//  CodeStack
//
//  Created by 박형환 on 12/10/23.
//

import ProjectDescription
import ProjectDescriptionHelpers


let dependencies: [TargetDependency] = [
    .PRO.domain,
    .PRO.data,
    .PRO.global,
    .PRO.csNetwork,
    .PRO.commonUI,
    .PRO.presentation,
]

let entitlementPath: Path = .relativeToCurrentFile("Resources/CodeStack.entitlements")

let resources: ResourceFileElements
= [
    "Resources/Apollo/codestackSchema.graphqls",
    "Resources/Apollo/graphqlQueries.graphql",
    "Resources/Assets.xcassets",
    "Resources/appstore.png",
    "Resources/style.css",
    "Resources/PLanguage/**/*.txt",
    "Resources/Base.lproj/*.storyboard",
    "Resources/GoogleService-Info.plist"
]

let project = Project.createModule(name: "CodestackApp",
                                   product: .app,
                                   includeTestTarget: true,
                                   bundleID: "kr.co.codestack.ios",
                                   settings: true,
                                   dependencies: dependencies,
                                   configuration: true,
                                   resources: resources,
                                   entitlement: entitlementPath,
                                   infoPlist: "Config/Info.plist")


