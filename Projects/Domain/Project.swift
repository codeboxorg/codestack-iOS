//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 12/14/23.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin


let project = ProjectFactory.createModuleWithDemo(
    name: "Domain",
    product: .staticFramework,
    dependencies: [
        .SPM.rxSwift,
        .PRO.global,
        .SPM.rxRelay
    ]
)

//let project = Project.createModule(
//    name: "Domain",
//    product: .staticFramework,
//    includeTestTarget: true,
//    hostTargetNeeded: true,
//    dependencies: [
////        .SPM.rxSwift,
////        .PRO.global,
////        .SPM.rxRelay
//    ]
//)

