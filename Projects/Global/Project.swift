//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 12/12/23.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(name: "Global",
                      organizationName: "hyeong",
                      options: .options(automaticSchemesOptions: .disabled),
                      packages: [],
                      settings: .settings(configurations: [
                        .debug(name: "Dev"),
                        .debug(name: "Prod")
                      ]),
                      targets: [
                        Project.target(name: "Global",
                                       product: .framework,
                                       sources: "Sources/**",
                                       resources: "Resources/**",
                                       dependencies: [
                                       ],
                                       configuration: [
                                        .debug(name: "Dev"),
                                        .debug(name: "Prod")
                                        ]),
                      ],
                      schemes: [
                        Scheme(name: "Global-Dev",
                               shared: true,
                               buildAction: .buildAction(targets: ["Global"]),
                               testAction: .targets(["GlobalTests"],
                                                    configuration: .configuration("Dev"),
                                                    options: .options(coverage: true)),
                               runAction: .runAction(configuration: .configuration("Dev"),
                                                     arguments: .init(environment: ["OS_ACTIVITY_MODE" : "disable"],
                                                                      launchArguments: [])),
                               archiveAction: .archiveAction(configuration: .configuration("Dev")),
                               profileAction: .profileAction(configuration: .configuration("Dev")),
                               analyzeAction: .analyzeAction(configuration: .configuration("Dev"))),
                        Scheme(name: "Global-Prod",
                               shared: true,
                               buildAction: .buildAction(targets: ["Global"]),
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
