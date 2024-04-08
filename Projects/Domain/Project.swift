//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 12/14/23.
//

import ProjectDescription
import ProjectDescriptionHelpers


let project = Project.createModule(name: "Domain",
                                   product: .staticFramework,
                                   includeTestTarget: true,
                                   hostTargetNeeded: true,
                                   dependencies: [
                                    .SPM.rxSwift,
                                    .PRO.global,
                                    .SPM.rxRelay
                                   ])

