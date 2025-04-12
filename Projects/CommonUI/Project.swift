//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 1/23/24.
//

@preconcurrency import ProjectDescription
import MyPlugin
import ProjectDescriptionHelpers

let project = ProjectFactory.createModuleWithDemo(
    name: "CommonUI",
    product: .staticFramework,
    dependencies: [
        .PRO.global,
        .SPM.then,
        .SPM.richtextKit,
        .SPM.highlightr,
        .SPM.snapKit,
        .SPM.swiftHanguel,
        .SPM.rxSwift
    ]
)
