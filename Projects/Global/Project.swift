//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 12/12/23.
//

import ProjectDescription
import ProjectDescriptionHelpers


let project = Project.createModule(name: "Global",
                                   product: .staticFramework,
                                   dependencies: [ .PRO.thridParty ],
                                   resources: "Resources/**")
