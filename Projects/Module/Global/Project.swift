//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 12/12/23.
//

@preconcurrency import ProjectDescription
@preconcurrency import ProjectDescriptionHelpers


let project = Project.createModule(name: "Global",
                                   product: .staticFramework,
                                   dependencies: [
                                    .SPM.snapKit,
                                    .SPM.then,
                                    .SPM.apollo,
                                    .SPM.richtextKit,
                                    .SPM.rxdatasources,
                                    .SPM.rxFlow,
                                    .SPM.rxGesture,
                                    .SPM.sqlite,
                                    .SPM.swinject,
                                    // .SPM.codestackAPI,
                                    .SPM.highlightr
                                   ],
                                   resources: "Resources/**")
