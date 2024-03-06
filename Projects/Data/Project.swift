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
    .PRO.domain,
    .PRO.csNetwork
   ]

let resources: ResourceFileElements = [
    "Resources/*.swift"
]

let paths = [
    "Sources/Data/MO/Class/db_model_v1.xcdatamodeld",
]

let coreDataPaths: [CoreDataModel] =
paths.map { path in
    CoreDataModel(Path.relativeToCurrentFile(path))
}

let baseSetting: SettingsDictionary =
["HEADER_SEARCH_PATHS": [
    "$(inherited)",
    "$(SRCROOT)/../../Tuist/Dependencies/SwiftPackageManager/.build/checkouts/GTMAppAuth/GTMAppAuth/Sources/Public/GTMAppAuth",
    "$(SRCROOT)/../../Tuist/Dependencies/SwiftPackageManager/.build/checkouts/gtm-session-fetcher/Sources/Core/Public"
],
 "OTHER_LDFLAGS" : "-ObjC"]

let value = Project.createModule(name: "Data",
                                 product: .staticFramework,
                                 dependencies: targetDependecies,
                                 baseSettings: baseSetting,
                                 coreDataModels: coreDataPaths,
                                 resources: resources)

