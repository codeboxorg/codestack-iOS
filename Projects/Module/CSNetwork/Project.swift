//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 12/17/23.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.createModule(name: "CSNetwork",
                                   product: .staticFramework,
                                   deploymentTarget: env15.deploymentTarget,
                                   dependencies: [.PRO.global])
