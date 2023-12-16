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
                                   dependencies: [ .PRO.global ],
                                   resources: "Resources/**")

