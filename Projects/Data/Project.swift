//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 12/12/23.
//

import ProjectDescription
import ProjectDescriptionHelpers


let project = Project(name: "Data",
                      organizationName: "hyeong",
                      options: .options(automaticSchemesOptions: .disabled),
                      packages: [],
                      settings: .settings(configurations: [
                        .debug(name: "Dev"),
                        .debug(name: "Prod")
                      ]),
                      targets: [
                        Project.target(name: "Data",
                                       product: .framework,
                                       sources: "Sources/**",
                                       resources: "Resources/**",
                                       dependencies: [
                                        .rxSwift,
                                        .codestackAPI,
                                       ],
                                       configuration: [
                                        .debug(name: "Dev"),
                                        .debug(name: "Prod")
                                        ]),
                      ],
                      schemes: [
                        Scheme(name: "Data-Dev",
                               shared: true,
                               buildAction: .buildAction(targets: ["Data"]),
                               testAction: .targets(["DataTests"],
                                                    configuration: .configuration("Dev"),
                                                    options: .options(coverage: true)),
                               runAction: .runAction(configuration: .configuration("Dev"),
                                                     arguments: .init(environment: ["OS_ACTIVITY_MODE" : "disable"],
                                                                      launchArguments: [])),
                               archiveAction: .archiveAction(configuration: .configuration("Dev")),
                               profileAction: .profileAction(configuration: .configuration("Dev")),
                               analyzeAction: .analyzeAction(configuration: .configuration("Dev"))),
                        Scheme(name: "Data-Prod",
                               shared: true,
                               buildAction: .buildAction(targets: ["Data"]),
                               runAction: .runAction(configuration: .configuration("Prod")),
                               archiveAction: .archiveAction(configuration: .configuration("Prod")),
                               profileAction: .profileAction(configuration: .configuration("Prod")),
                               analyzeAction: .analyzeAction(configuration: .configuration("Prod")))
                      ],
                      fileHeaderTemplate: nil,
                      additionalFiles: [],
                      resourceSynthesizers: [])

//                        Project.target(name: "MyAppTests",
//                                       product: .unitTests,
//                                       sources: "Tests/**",
//                                       dependencies: [
//                                        .target(name: "MyApp"),
//                                       ])
