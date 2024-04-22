//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 1/23/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.createModule(name: "CommonUI",
                                   product: .staticFramework,
                                   dependencies: [.PRO.global,
                                                  .SPM.snapKit,
                                                  .SPM.swiftHanguel,
                                                  .SPM.rxSwift,])
