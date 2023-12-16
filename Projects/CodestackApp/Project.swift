//
//  Project.swift
//  CodeStack
//
//  Created by 박형환 on 12/10/23.
//

import ProjectDescription
import ProjectDescriptionHelpers


let dependencies: [TargetDependency] = [
    .PRO.data,
    .PRO.domain
]

let entitlementPath: ProjectDescription.Path = .relativeToCurrentFile("Resources/CodeStack.entitlements")

let resources: ResourceFileElements
= [
    "Resources/Apollo/codestackSchema.graphqls",
    "Resources/Apollo/graphqlQueries.graphql",
    "Resources/Assets.xcassets",
    "Resources/appstore.png",
    "Resources/style.css",
    "Resources/PLanguage/c/*.txt",
    "Resources/PLanguage/c++/*.txt",
    "Resources/PLanguage/cpp/*.txt",
    "Resources/PLanguage/go/*.txt",
    "Resources/PLanguage/java/*.txt",
    "Resources/PLanguage/javascript/*.txt",
    "Resources/PLanguage/kotlin/*.txt",
    "Resources/PLanguage/nodejs/*.txt",
    "Resources/PLanguage/python3/*.txt",
    "Resources/PLanguage/swift/*.txt",
    "Resources/PLanguage/typescript/*.txt",
    "Resources/Base.lproj/LaunchScreen.storyboard"
]

let project = Project.createModule(name: "CodestackApp",
                                   product: .app,
                                   bundleID: "kr.co.codestack.ios",
                                   settings: true,
                                   dependencies: dependencies,
                                   configuration: true,
                                   resources: resources,
                                   entitlement: entitlementPath,
                                   infoPlist: "Config/Info.plist")


