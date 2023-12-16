//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 12/12/23.
//

import ProjectDescription
import ProjectDescriptionHelpers



let targetDependecies: [TargetDependency] = [
    .PRO.global,
    .PRO.domain
   ]

let resources: ResourceFileElements = [
    "Sources/Data/MO/db_model_v1.xcdatamodeld",
    "Resources/**"
]

let value = Project.createModule(name: "Data",
                                 product: .staticFramework,
                                 dependencies: targetDependecies,
                                 resources: resources)

