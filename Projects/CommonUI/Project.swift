//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 1/23/24.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin

let name = "CommonUI"
let project = ProjectFactory.createModuleWithDemo(
    name: name,
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
