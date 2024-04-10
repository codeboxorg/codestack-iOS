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
    .PRO.thridParty,
    .PRO.domain,
    .PRO.csNetwork,
    .SPM.firebaseAuth
   ]

let resources: ResourceFileElements = []

let paths = [
    "Sources/Data/MO/Class/db_model_v1.xcdatamodeld",
]

let coreDataPaths: [CoreDataModel] =
paths.map { path in
    CoreDataModel.coreDataModel(Path.relativeToCurrentFile(path))
}

let baseSetting: SettingsDictionary =
["HEADER_SEARCH_PATHS": [
    "$(inherited)",
    "$(SRCROOT)/../../Tuist/Dependencies/SwiftPackageManager/.build/checkouts/GTMAppAuth/GTMAppAuth/Sources/Public/GTMAppAuth",
    "$(SRCROOT)/../../Tuist/Dependencies/SwiftPackageManager/.build/checkouts/gtm-session-fetcher/Sources/Core/Public"
],
 "OTHER_LDFLAGS" : "$(OTHER_LDFLAGS) -ObjC"]

let value = Project.createModule(name: "Data",
                                 product: .staticFramework,
                                 includeTestTarget: true,
                                 hostTargetNeeded: true,
                                 dependencies: targetDependecies,
                                 baseSettings: baseSetting,
                                 coreDataModels: coreDataPaths,
                                 resources: resources)

