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
    .PRO.thridParty,
    .PRO.global,
    .PRO.csNetwork,
    .PRO.commonUI,
    .SPM.rxdatasources,
    .SPM.rxFlow,
    .SPM.rxSwift,
    .SPM.rxGesture,
    .SPM.richText,
    .SPM.richtextKit,
        .SPM.swiftDown
    // .PRO.presentation,
]

let entitlementPath: Entitlements = .file(path: .path("Resources/CodeStack.entitlements"))

let resources: ResourceFileElements
= [
    "Resources/Apollo/codestackSchema.graphqls",
    "Resources/Apollo/graphqlQueries.graphql",
    "Resources/Asset/*.*",
    "Resources/knight-warrior-font/KnightWarrior-w16n8.otf",
    "Resources/**",
    "Resources/PLanguage/**/*.txt",
    // "Resources/Base.lproj/*.storyboard",
    "Resources/GoogleService-Info.plist",
    "Config/GoogleService-Info.plist"
]

let project = Project.createModule(name: "CodestackApp",
                                   product: .app,
                                   includeTestTarget: true,
                                   bundleID: "kr.co.codestack.ios",
                                   packages: [],
                                   settings: true,
                                   dependencies: dependencies,
                                   baseSettings: CSettings.cmark.value,
                                   configuration: true,
                                   resources: resources,
                                   entitlement: entitlementPath,
                                   script: [.BuildScript],
                                   infoPlist: "Config/Info.plist")
