//
//  Project.swift
//  CodeStack
//
//  Created by 박형환 on 12/10/23.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin


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
]

let mode: String = {
    if case let .string(value) = Environment.MODE {
        return value
    }
    return "all"
}()

let env_dependencies: [TargetDependency] = {
    switch mode {
    case "commonUIDemo":
        debugPrint("CommonUIJDIFJSKJFS")
        return [] // ✅ CommonUI 데모 모드에서는 Data 모듈 제외
    default:
        return dependencies
    }
}()

let entitlementPath: Entitlements = .file(path: .path("Resources/CodeStack.entitlements"))

let resources: ResourceFileElements
= [
    "Resources/Asset/*.*",
    "Resources/knight-warrior-font/KnightWarrior-w16n8.otf",
    "Resources/**",
    "Resources/PLanguage/**/*.txt",
    "Resources/GoogleService-Info.plist",
    "Config/GoogleService-Info.plist"
]


let name = "CodestackApp"

let project = ProjectFactory.createApp(
    name: name,
    product: .app,
    resources: resources,
    dependencies: dependencies,
    infoPlist: .file(path: .relativeToRoot("Config/Info.plist"))
)
