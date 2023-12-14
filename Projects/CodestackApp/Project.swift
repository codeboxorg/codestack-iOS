//
//  Project.swift
//  CodeStack
//
//  Created by 박형환 on 12/10/23.
//

import ProjectDescription
import ProjectDescriptionHelpers

let resources: ResourceFileElements
= [
    "Resources/Apollo/codestackSchema.graphqls",
    "Resources/Apollo/graphqlQueries.graphql",
    "Resources/Assets.xcassets",
    "Resources/appstore.png",
    "Resources/style.css",
    "Resources/PLanguage/c/*.txt",
    "Resources/PLanguage/c++/*.txt",
    "Resources/PLanguage/cpp/*.txt",
    "Resources/PLanguage/go/*.txt",
    "Resources/PLanguage/java/*.txt",
    "Resources/PLanguage/javascript/*.txt",
    "Resources/PLanguage/kotlin/*.txt",
    "Resources/PLanguage/nodejs/*.txt",
    "Resources/PLanguage/python3/*.txt",
    "Resources/PLanguage/swift/*.txt",
    "Resources/PLanguage/typescript/*.txt",
    "Resources/Base.lproj/LaunchScreen.storyboard",
    "Sources/Data/MO/db_model_v1.xcdatamodeld"
]


let project = Project(name: "CodestackApp",
                      organizationName: "hyeong",
                      options: .options(automaticSchemesOptions: .disabled),
                      packages: [],
                      settings: .settings(configurations: [
                        .debug(name: "Dev",
                               settings: [:],
                               xcconfig: "Config/BuildSetting.xcconfig"),
                        .debug(name: "Prod",
                               settings: [:],
                               xcconfig: "Config/BuildSetting.xcconfig"),
                      ]),
                      targets: [
                        Project.target(name: "CodestackApp",
                                       product: .app,
                                       bundleID: "kr.co.codestack.ios",
                                       infoPlist: "Config/Info.plist",
                                       sources: "Sources/**",
                                       resources: resources,
                                       entitlement: .relativeToCurrentFile("Resources/CodeStack.entitlements"),
                                       dependencies: [
                                        .project(target: "Global", path: .relativeToRoot("Projects/Global")),
                                        .project(target: "Data", path: .relativeToRoot("Projects/Data")),
                                        .project(target: "Domain", path: .relativeToRoot("Projects/Domain")),
                                        .rxSwift,
                                        .snapKit,
                                        .then,
                                        .apollo,
                                        .richtextKit,
                                        .rxdatasources,
                                        .rxFlow,
                                        .rxGesture,
                                        .sqlite,
                                        .swinject,
                                        .codestackAPI,
                                        .highlightr,
                                       ],
                                       configuration: [
                                        .debug(name: "Dev",
                                               settings: [:],
                                               xcconfig: "Config/Codestack.xcconfig"),
                                        .debug(name: "Prod",
                                               settings: [:],
                                               xcconfig: "Config/Codestack.xcconfig")
                                       ]),
                      ],
                      schemes: [
                        Scheme(name: "CodestackApp-Dev",
                               shared: true,
                               buildAction: .buildAction(targets: ["CodestackApp"]),
                               testAction: .targets(["MyAppTests"],
                                                    configuration: .configuration("Dev"),
                                                    options: .options(coverage: true)),
                               runAction: .runAction(configuration: .configuration("Dev"),
                                                     arguments: .init(environment: ["OS_ACTIVITY_MODE" : "disable"],
                                                                      launchArguments: [])),
                               archiveAction: .archiveAction(configuration: .configuration("Dev")),
                               profileAction: .profileAction(configuration: .configuration("Dev")),
                               analyzeAction: .analyzeAction(configuration: .configuration("Dev"))),
                        Scheme(name: "CodestackApp-Prod",
                               shared: true,
                               buildAction: .buildAction(targets: ["CodestackApp"]),
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
