//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 12/16/23.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin

let project = ProjectFactory
    .createModule(
        name: "ThirdParty",
        product: .staticFramework,
        dependencies: [
            .SPM.rxSwift,
            .SPM.snapKit,
            .SPM.then,
            .SPM.apollo,
            .SPM.richtextKit,
            .SPM.rxdatasources,
            .SPM.rxFlow,
            .SPM.rxGesture,
            .SPM.swinject,
            .SPM.highlightr,
            .SPM.richText,
            .SPM.firebaseAnalyticsSwift,
            .SPM.reactorKit
        ]
    )
//let project = Project.createModule(name: "ThirdParty",
//                                   product: .staticFramework,
//                                   dependencies: [.SPM.rxSwift,
//                                                  .SPM.snapKit,
//                                                  .SPM.then,
//                                                  .SPM.apollo,
//                                                  .SPM.richtextKit,
//                                                  .SPM.rxdatasources,
//                                                  .SPM.rxFlow,
//                                                  .SPM.rxGesture,
//                                                  .SPM.swinject,
//                                                  // .SPM.codestackAPI,
//                                                  .SPM.highlightr,
//                                                  .SPM.richText,
//                                                  .SPM.firebaseAnalyticsSwift,
//                                                  .SPM.reactorKit
//                                   ],
//                                   baseSettings: CSettings.objc.value)
//
